# -*- encoding:utf-8 -*-

# API用の部屋コントローラ（CosmosのReactアプリ用）
class Api::V1::RoomsController < ApplicationController
  # CSRFトークンの検証を無効化（API用）
  skip_before_action :verify_authenticity_token
  
  # CORS対応
  before_action :set_cors_headers
  before_action :set_property
  before_action :set_room, only: [:show, :update, :destroy]
  
  # 物件の部屋一覧取得
  def index
    begin
      rooms = @property.rooms.includes(:room_type, :room_layout, :room_status)
      
      rooms_data = rooms.map do |room|
        {
          id: room.id,
          name: room.name,
          floor: room.floor,
          area: room.area,
          rent: room.rent,
          management_fee: room.management_fee,
          deposit: room.deposit,
          key_money: room.key_money,
          room_layout_id: room.room_layout_id,
          room_layout_name: room.room_layout&.name,
          room_status_id: room.room_status_id,
          room_status_name: room.room_status&.name,
          free_state: room.free_state,
          description: room.description,
          created_at: room.created_at,
          updated_at: room.updated_at
        }
      end
      
      render json: {
        status: 'success',
        data: rooms_data
      }
      
    rescue => e
      Rails.logger.error "RoomsController#index error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      render json: {
        status: 'error',
        message: '部屋一覧の取得に失敗しました',
        error: e.message
      }, status: 500
    end
  end
  
  # 部屋詳細取得
  def show
    begin
      render json: {
        status: 'success',
        data: {
          id: @room.id,
          name: @room.name,
          floor: @room.floor,
          area: @room.area,
          rent: @room.rent,
          management_fee: @room.management_fee,
          deposit: @room.deposit,
          key_money: @room.key_money,
          room_layout_id: @room.room_layout_id,
          room_layout_name: @room.room_layout&.name,
          room_status_id: @room.room_status_id,
          room_status_name: @room.room_status&.name,
          free_state: @room.free_state,
          description: @room.description,
          building_id: @room.building_id,
          created_at: @room.created_at,
          updated_at: @room.updated_at
        }
      }
      
    rescue => e
      Rails.logger.error "RoomsController#show error: #{e.message}"
      
      render json: {
        status: 'error',
        message: '部屋詳細の取得に失敗しました',
        error: e.message
      }, status: 500
    end
  end
  
  # 部屋作成
  def create
    begin
      room_params = params.require(:room).permit(
        :name, :floor, :area, :rent, :management_fee, :deposit, :key_money,
        :room_layout_id, :room_status_id, :description
      )
      
      # 空室状態を設定（room_status_idが'1'（空室）の場合はfree_state=1）
      room_params[:free_state] = room_params[:room_status_id] == '1' ? 1 : 0
      room_params[:building_id] = @property.id
      
      room = Room.new(room_params)
      
      if room.save
        render json: {
          status: 'success',
          message: '部屋を作成しました',
          data: {
            id: room.id,
            name: room.name,
            floor: room.floor,
            area: room.area,
            rent: room.rent,
            management_fee: room.management_fee,
            deposit: room.deposit,
            key_money: room.key_money,
            room_layout_id: room.room_layout_id,
            room_status_id: room.room_status_id,
            free_state: room.free_state,
            description: room.description,
            building_id: room.building_id,
            created_at: room.created_at,
            updated_at: room.updated_at
          }
        }, status: 201
      else
        render json: {
          status: 'error',
          message: '部屋の作成に失敗しました',
          errors: room.errors.full_messages
        }, status: 422
      end
      
    rescue => e
      Rails.logger.error "RoomsController#create error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      render json: {
        status: 'error',
        message: '部屋の作成に失敗しました',
        error: e.message
      }, status: 500
    end
  end
  
  # 部屋更新
  def update
    begin
      room_params = params.require(:room).permit(
        :name, :floor, :area, :rent, :management_fee, :deposit, :key_money,
        :room_layout_id, :room_status_id, :description
      )
      
      # 空室状態を設定
      room_params[:free_state] = room_params[:room_status_id] == '1' ? 1 : 0
      
      if @room.update(room_params)
        render json: {
          status: 'success',
          message: '部屋情報を更新しました',
          data: {
            id: @room.id,
            name: @room.name,
            floor: @room.floor,
            area: @room.area,
            rent: @room.rent,
            management_fee: @room.management_fee,
            deposit: @room.deposit,
            key_money: @room.key_money,
            room_layout_id: @room.room_layout_id,
            room_status_id: @room.room_status_id,
            free_state: @room.free_state,
            description: @room.description,
            updated_at: @room.updated_at
          }
        }
      else
        render json: {
          status: 'error',
          message: '部屋情報の更新に失敗しました',
          errors: @room.errors.full_messages
        }, status: 422
      end
      
    rescue => e
      Rails.logger.error "RoomsController#update error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      render json: {
        status: 'error',
        message: '部屋情報の更新に失敗しました',
        error: e.message
      }, status: 500
    end
  end
  
  # 部屋削除
  def destroy
    begin
      if @room.destroy
        render json: {
          status: 'success',
          message: '部屋を削除しました'
        }
      else
        render json: {
          status: 'error',
          message: '部屋の削除に失敗しました',
          errors: @room.errors.full_messages
        }, status: 422
      end
      
    rescue => e
      Rails.logger.error "RoomsController#destroy error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      render json: {
        status: 'error',
        message: '部屋の削除に失敗しました',
        error: e.message
      }, status: 500
    end
  end
  
  # CORS preflight request
  def options
    head :ok
  end
  
  private
  
  def set_cors_headers
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
  end
  
  def set_property
    @property = Building.find(params[:property_id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: 'error',
      message: '物件が見つかりません'
    }, status: 404
  end
  
  def set_room
    @room = @property.rooms.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: 'error',
      message: '部屋が見つかりません'
    }, status: 404
  end
end