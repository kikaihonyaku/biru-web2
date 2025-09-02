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
      # 建物種別の値マッピング
      building_type_code = map_building_type_to_code(search_conditions[:building_type])
      if building_type_code
        where_conditions << "bt.code = :building_type"
        where_params[:building_type] = building_type_code
      end
    end
    
    if search_conditions[:management_type].present?
      # 管理方式の値マッピング
      management_type_code = map_management_type_to_code(search_conditions[:management_type])
      if management_type_code
        where_conditions << "mt.code = :management_type"
        where_params[:management_type] = management_type_code
      end
    end
    
    # 戸数条件は集計後のCOUNT値に対する条件なので、HAVING句で処理する必要がある
    # ここでは簡略化のため、コメントアウトして後で実装
    # if search_conditions[:min_rooms].present?
    #   where_conditions << "COUNT(r.id) >= :min_rooms"
    #   where_params[:min_rooms] = search_conditions[:min_rooms].to_i
    # end
    
    # if search_conditions[:max_rooms].present?
    #   where_conditions << "COUNT(r.id) <= :max_rooms"
    #   where_params[:max_rooms] = search_conditions[:max_rooms].to_i
    # end
    
    # if search_conditions[:max_vacancy_rate].present?
    #   where_conditions << "CASE WHEN COUNT(r.id) > 0 THEN (SUM(CASE WHEN r.free_state = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(r.id)) ELSE 0 END <= :max_vacancy_rate"
    #   where_params[:max_vacancy_rate] = search_conditions[:max_vacancy_rate].to_f
    # end
    
    if search_conditions[:min_age].present?
      where_conditions << "ISNULL(b.biru_age, 0) >= :min_age"
      where_params[:min_age] = search_conditions[:min_age].to_i
    end
    
    if search_conditions[:max_age].present?
      where_conditions << "ISNULL(b.biru_age, 0) <= :max_age"
      where_params[:max_age] = search_conditions[:max_age].to_i
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
  
  # 建物種別のフロントエンド値をDB値にマッピング
  def map_building_type_to_code(building_type)
    mapping = {
      'apartment' => '01020',    # アパート
      'mansion' => '01010',      # マンション
      'house' => '01025',        # 戸建て
      'other' => '01030'         # その他
    }
    mapping[building_type]
  end
  
  # 管理方式のフロントエンド値をDB値にマッピング
  def map_management_type_to_code(management_type)
    mapping = {
      'full' => '3',       # 一括管理（B管理）
      'partial' => '2',    # 一部管理（A管理）
      'none' => '1'        # 管理なし（一般）
    }
    mapping[management_type]
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
        COUNT(r.id) as room_cnt,
        SUM(CASE WHEN r.free_state = 1 THEN 1 ELSE 0 END) as free_cnt,
        CASE 
          WHEN COUNT(r.id) > 0 
          THEN ROUND((SUM(CASE WHEN r.free_state = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(r.id)), 1)
          ELSE 0
        END as vacancy_rate,
        ISNULL(b.biru_age, 0) as age,
        s.code as shop_code,
        s.name as shop_name
      FROM biru.buildings b
      INNER JOIN biru.rooms r ON b.id = r.building_id
      INNER JOIN biru.shops s ON b.shop_id = s.id
      LEFT JOIN biru.build_types bt ON b.build_type_id = bt.id
      LEFT JOIN biru.manage_types mt ON r.manage_type_id = mt.id
      WHERE b.latitude IS NOT NULL 
        AND b.longitude IS NOT NULL
        AND b.delete_flg = 0
        AND r.delete_flg = 0
        #{where_clause.present? ? "AND (#{where_clause})" : ''}
      GROUP BY b.id, b.code, b.name, b.address, b.latitude, b.longitude,
               bt.code, bt.name, bt.icon, mt.code, mt.name, mt.icon,
               b.biru_age, s.code, s.name
      ORDER BY b.id
    SQL
  end
end