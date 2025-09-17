# -*- encoding:utf-8 -*-

# API用の物件写真コントローラ（CosmosのReactアプリ用）
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
      # 写真ディレクトリのパスを構築
      photos_dir = Rails.root.join('public', 'property_photos', @property.id.to_s)
      photos_data = []
      
      if Dir.exist?(photos_dir)
        Dir.glob(File.join(photos_dir, '*')).each_with_index do |file_path, index|
          next unless File.file?(file_path)
          next unless ['.jpg', '.jpeg', '.png', '.gif'].include?(File.extname(file_path).downcase)
          
          filename = File.basename(file_path)
          photos_data << {
            id: index + 1,
            filename: filename,
            url: "/property_photos/#{@property.id}/#{filename}",
            thumbnail_url: "/property_photos/#{@property.id}/thumb_#{filename}",
            size: File.size(file_path),
            created_at: File.mtime(file_path)
          }
        end
      end
      
      render json: {
        status: 'success',
        data: photos_data.sort_by { |photo| photo[:created_at] }
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
  
  # 写真アップロード
  def create
    begin
      uploaded_file = params[:photo]
      
      unless uploaded_file
        render json: {
          status: 'error',
          message: 'ファイルが選択されていません'
        }, status: 400
        return
      end
      
      # ファイル形式チェック
      unless ['image/jpeg', 'image/png', 'image/gif'].include?(uploaded_file.content_type)
        render json: {
          status: 'error',
          message: 'サポートされていないファイル形式です'
        }, status: 400
        return
      end
      
      # ディレクトリ作成
      photos_dir = Rails.root.join('public', 'property_photos', @property.id.to_s)
      FileUtils.mkdir_p(photos_dir)
      
      # ファイル名生成（タイムスタンプ + オリジナル名）
      timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
      original_filename = uploaded_file.original_filename
      extension = File.extname(original_filename)
      base_name = File.basename(original_filename, extension)
      safe_filename = "#{timestamp}_#{base_name.gsub(/[^0-9A-Za-z.\-]/, '_')}#{extension}"
      
      # ファイル保存
      file_path = File.join(photos_dir, safe_filename)
      File.open(file_path, 'wb') do |file|
        file.write(uploaded_file.read)
      end
      
      # サムネイル生成（簡易版）
      create_thumbnail(file_path, photos_dir, safe_filename)
      
      render json: {
        status: 'success',
        message: '写真をアップロードしました',
        data: {
          filename: safe_filename,
          url: "/property_photos/#{@property.id}/#{safe_filename}",
          thumbnail_url: "/property_photos/#{@property.id}/thumb_#{safe_filename}",
          size: File.size(file_path)
        }
      }, status: 201
      
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
      filename = params[:id]
      photos_dir = Rails.root.join('public', 'property_photos', @property.id.to_s)
      
      file_path = File.join(photos_dir, filename)
      thumb_path = File.join(photos_dir, "thumb_#{filename}")
      
      # ファイル削除
      File.delete(file_path) if File.exist?(file_path)
      File.delete(thumb_path) if File.exist?(thumb_path)
      
      render json: {
        status: 'success',
        message: '写真を削除しました'
      }
      
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
    # ファイル存在チェック
    filename = params[:id]
    photos_dir = Rails.root.join('public', 'property_photos', @property.id.to_s)
    file_path = File.join(photos_dir, filename)
    
    unless File.exist?(file_path)
      render json: {
        status: 'error',
        message: '写真が見つかりません'
      }, status: 404
    end
  end
  
  # 簡易サムネイル生成（ImageMagick不要版）
  def create_thumbnail(original_path, photos_dir, filename)
    begin
      # サムネイルは元画像をコピーして作成（本来はリサイズ処理）
      thumb_filename = "thumb_#{filename}"
      thumb_path = File.join(photos_dir, thumb_filename)
      FileUtils.copy(original_path, thumb_path)
    rescue => e
      Rails.logger.warn "サムネイル生成に失敗: #{e.message}"
    end
  end
end