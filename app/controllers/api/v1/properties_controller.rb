# -*- encoding:utf-8 -*-

# API用の物件コントローラ（CosmosのReactアプリ用）
class Api::V1::PropertiesController < ApplicationController
  # CSRFトークンの検証を無効化（API用）
  skip_before_action :verify_authenticity_token
  
  # CORS対応
  before_action :set_cors_headers
  
  # 地図表示用の物件データを取得
  def map_data
    # パラメータの取得
    shop_codes = params[:shop_codes]&.split(',') || []
    search_conditions = params[:search] || {}
    
    # 基本的なWHERE条件を構築
    where_conditions = []
    where_params = {}
    
    # 営業所の絞り込み
    unless shop_codes.empty?
      where_conditions << "s.code IN (#{shop_codes.map { |code| "'#{code}'" }.join(',')})"
    end
    
    # 検索条件の適用
    if search_conditions[:property_name].present?
      where_conditions << "b.name LIKE :property_name"
      where_params[:property_name] = "%#{search_conditions[:property_name]}%"
    end
    
    if search_conditions[:address].present?
      where_conditions << "b.address LIKE :address"
      where_params[:address] = "%#{search_conditions[:address]}%"
    end
    
    if search_conditions[:building_type].present?
      where_conditions << "bt.code = :building_type"
      where_params[:building_type] = search_conditions[:building_type]
    end
    
    if search_conditions[:min_rooms].present?
      where_conditions << "b.room_cnt >= :min_rooms"
      where_params[:min_rooms] = search_conditions[:min_rooms].to_i
    end
    
    if search_conditions[:max_rooms].present?
      where_conditions << "b.room_cnt <= :max_rooms"
      where_params[:max_rooms] = search_conditions[:max_rooms].to_i
    end
    
    if search_conditions[:max_vacancy_rate].present?
      where_conditions << "CASE WHEN b.room_cnt > 0 THEN (b.free_cnt * 100.0 / b.room_cnt) ELSE 0 END <= :max_vacancy_rate"
      where_params[:max_vacancy_rate] = search_conditions[:max_vacancy_rate].to_f
    end
    
    # SQLクエリの構築
    sql = build_properties_sql(where_conditions.join(' AND '))
    
    # クエリの実行
    results = ActiveRecord::Base.connection.select_all(
      ActiveRecord::Base.send(:sanitize_sql_array, [sql, where_params])
    )
    
    # データの整形
    buildings = results.map do |row|
      {
        id: row['id'].to_i,
        name: row['name'],
        code: row['code'],
        address: row['address'],
        latitude: row['latitude'].to_f,
        longitude: row['longitude'].to_f,
        build_type: row['build_type'],
        build_type_name: row['build_type_name'],
        build_type_icon: row['build_type_icon'],
        manage_type: row['manage_type'],
        manage_type_name: row['manage_type_name'],
        manage_type_icon: row['manage_type_icon'],
        room_cnt: row['room_cnt'].to_i,
        free_cnt: row['free_cnt'].to_i,
        vacancy_rate: row['vacancy_rate'].to_f,
        age: row['age'].to_i,
        shop_code: row['shop_code'],
        shop_name: row['shop_name']
      }
    end
    
    render json: {
      status: 'success',
      data: {
        buildings: buildings,
        total_count: buildings.length
      }
    }
    
  rescue => e
    Rails.logger.error "PropertiesController#map_data error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    
    render json: {
      status: 'error',
      message: 'データの取得に失敗しました',
      error: e.message
    }, status: 500
  end
  
  # 物件検索
  def search
    search_params = params.permit(:property_name, :address, :building_type, :management_type, 
                                  :min_rooms, :max_rooms, :max_vacancy_rate, :min_age, :max_age)
    
    # map_dataメソッドを再利用
    params[:search] = search_params.to_h
    map_data
  end
  
  private
  
  def set_cors_headers
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
  end
  
  def build_properties_sql(where_clause = '')
    <<~SQL
      SELECT 
        b.id,
        b.code,
        b.name,
        b.address,
        b.latitude,
        b.longitude,
        bt.code as build_type,
        bt.name as build_type_name,
        bt.icon as build_type_icon,
        mt.code as manage_type,
        mt.name as manage_type_name,
        mt.icon as manage_type_icon,
        ISNULL(b.room_cnt, 0) as room_cnt,
        ISNULL(b.free_cnt, 0) as free_cnt,
        CASE 
          WHEN ISNULL(b.room_cnt, 0) > 0 
          THEN ROUND((ISNULL(b.free_cnt, 0) * 100.0 / b.room_cnt), 1)
          ELSE 0
        END as vacancy_rate,
        CASE 
          WHEN b.build_day IS NOT NULL 
          THEN DATEDIFF(year, b.build_day, GETDATE())
          ELSE 0
        END as age,
        s.code as shop_code,
        s.name as shop_name
      FROM biru.buildings b
      LEFT JOIN biru.build_types bt ON b.build_type_id = bt.id
      LEFT JOIN biru.manage_types mt ON b.manage_type_id = mt.id
      LEFT JOIN biru.shops s ON b.shop_id = s.id
      WHERE b.latitude IS NOT NULL 
        AND b.longitude IS NOT NULL
        AND b.del_flg = 0
        #{where_clause.present? ? "AND (#{where_clause})" : ''}
      ORDER BY b.id
    SQL
  end
end