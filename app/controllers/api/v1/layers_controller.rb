# -*- encoding:utf-8 -*-

# API用のレイヤーコントローラ（CosmosのReactアプリ用）
class Api::V1::LayersController < ApplicationController
  # CSRFトークンの検証を無効化（API用）
  skip_before_action :verify_authenticity_token
  
  # CORS対応
  before_action :set_cors_headers
  
  # レイヤーデータを取得
  def show
    layer_type = params[:type]
    
    case layer_type
    when 'stations'
      render json: get_stations_data
    when 'lines'
      render json: get_lines_data
    when 'school-district'
      render json: get_school_district_data
    when 'commercial'
      render json: get_commercial_data
    else
      render json: {
        status: 'error',
        message: "Unknown layer type: #{layer_type}"
      }, status: 400
    end
    
  rescue => e
    Rails.logger.error "LayersController#show error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    
    render json: {
      status: 'error',
      message: 'レイヤーデータの取得に失敗しました',
      error: e.message
    }, status: 500
  end
  
  private
  
  def set_cors_headers
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
  end
  
  # 駅データを取得
  def get_stations_data
    sql = <<~SQL
      SELECT 
        s.id,
        s.name,
        s.latitude,
        s.longitude,
        s.line_name,
        l.name as line_full_name,
        l.color as line_color
      FROM biru.stations s
      LEFT JOIN biru.lines l ON s.line_id = l.id
      WHERE s.latitude IS NOT NULL 
        AND s.longitude IS NOT NULL
      ORDER BY s.name
    SQL
    
    results = ActiveRecord::Base.connection.select_all(sql)
    
    stations = results.map do |row|
      {
        id: row['id'].to_i,
        name: row['name'],
        latitude: row['latitude'].to_f,
        longitude: row['longitude'].to_f,
        line_name: row['line_name'],
        line_full_name: row['line_full_name'],
        line_color: row['line_color']
      }
    end
    
    {
      status: 'success',
      layer_type: 'stations',
      data: stations
    }
  end
  
  # 路線データを取得
  def get_lines_data
    sql = <<~SQL
      SELECT 
        l.id,
        l.name,
        l.color,
        l.icon
      FROM biru.lines l
      ORDER BY l.name
    SQL
    
    results = ActiveRecord::Base.connection.select_all(sql)
    
    lines = results.map do |row|
      {
        id: row['id'].to_i,
        name: row['name'],
        color: row['color'],
        icon: row['icon']
      }
    end
    
    {
      status: 'success',
      layer_type: 'lines',
      data: lines
    }
  end
  
  # 学区レイヤー（サンプルデータ）
  def get_school_district_data
    # 実際のデータがない場合のサンプル
    sample_districts = [
      {
        id: 1,
        name: '浦和区第一小学校区',
        type: 'elementary',
        boundaries: [
          { lat: 35.8617, lng: 139.6455 },
          { lat: 35.8650, lng: 139.6455 },
          { lat: 35.8650, lng: 139.6500 },
          { lat: 35.8617, lng: 139.6500 }
        ]
      }
    ]
    
    {
      status: 'success',
      layer_type: 'school-district',
      data: sample_districts
    }
  end
  
  # 商業施設レイヤー（サンプルデータ）
  def get_commercial_data
    # 実際のデータがない場合のサンプル
    sample_facilities = [
      {
        id: 1,
        name: 'イオン浦和店',
        type: 'shopping_mall',
        latitude: 35.8600,
        longitude: 139.6470
      }
    ]
    
    {
      status: 'success',
      layer_type: 'commercial',
      data: sample_facilities
    }
  end
end