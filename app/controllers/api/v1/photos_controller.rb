# -*- encoding:utf-8 -*-

# API用の写真コントローラ（CosmosのReactアプリ用）
class Api::V1::PhotosController < ApplicationController
  # CSRFトークンの検証を無効化（API用）
  skip_before_action :verify_authenticity_token
  
  # CORS対応
  before_action :set_cors_headers
  before_action :set_property
  before_action :set_photo, only: [:show, :destroy]
  
  # 物件の写真一覧取得
  def index
    begin
      # 現在は空の配列を返す（後で実装）
      render json: {
        status: 'success',
        data: []
      }
      
    rescue => e
      Rails.logger.error "PhotosController#index error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      render json: {
        status: 'error',
        message: '写真一覧の取得に失敗しました',
        error: e.message
      }, status: 500
    end
  end
  
  # 写真詳細取得
  def show
    begin
      render json: {
        status: 'success',
        data: {
          id: @photo.id,
          filename: @photo.filename,
          url: @photo.url,
          caption: @photo.caption,
          created_at: @photo.created_at,
          updated_at: @photo.updated_at
        }
      }
      
    rescue => e
      Rails.logger.error "PhotosController#show error: #{e.message}"
      
      render json: {
        status: 'error',
        message: '写真詳細の取得に失敗しました',
        error: e.message
      }, status: 500
    end
  end
  
  # 写真アップロード
  def create
    begin
      # 現在は未実装
      render json: {
        status: 'error',
        message: '写真アップロード機能は未実装です'
      }, status: 501
      
    rescue => e
      Rails.logger.error "PhotosController#create error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      render json: {
        status: 'error',
        message: '写真のアップロードに失敗しました',
        error: e.message
      }, status: 500
    end
  end
  
  # 写真削除
  def destroy
    begin
      # 現在は未実装
      render json: {
        status: 'error',
        message: '写真削除機能は未実装です'
      }, status: 501
      
    rescue => e
      Rails.logger.error "PhotosController#destroy error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      render json: {
        status: 'error',
        message: '写真の削除に失敗しました',
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
  
  def set_photo
    # 写真モデルが存在する場合の実装例
    # @photo = @property.photos.find(params[:id])
    render json: {
      status: 'error', 
      message: '写真が見つかりません'
    }, status: 404
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: 'error',
      message: '写真が見つかりません'
    }, status: 404
  end
end