# -*- encoding:utf-8 -*-

class Api::V1::AuthController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_cors_headers
  
  # 既存認証（社員番号・パスワード）
  def login
    code = params[:code]
    password = params[:password]
    
    if code.blank? || password.blank?
      render json: { error: '社員番号とパスワードを入力してください' }, status: 400
      return
    end
    
    user = authenticate_user_with_code_normalization(code, password)
    
    if user
      # ログイン履歴の保存
      save_login_history(user)
      
      # セッションに保存
      session[:biru_user] = user.id
      
      render json: {
        success: true,
        user: {
          id: user.id,
          code: format_employee_code(code),  # 入力コードを5桁にフォーマット
          name: user.name,
          email: user.email,
          auth_provider: user.auth_provider || 'local'
        }
      }
    else
      render json: { error: 'IDまたはパスワードに誤りがあります。正しい社員番号とパスワードを入力してください。' }, status: 401
    end
  end
  
  # Google OAuth認証開始
  def google_auth
    redirect_to '/auth/google', allow_other_host: true
  end
  
  # Google OAuth コールバック
  def google_callback
    omniauth_data = request.env['omniauth.auth']
    
    if omniauth_data.blank?
      render json: { error: 'Google認証に失敗しました' }, status: 400
      return
    end
    
    begin
      user = BiruUser.find_or_create_by_google(omniauth_data)
      
      # ログイン履歴の保存
      save_login_history(user)
      
      # セッションに保存
      session[:biru_user] = user.id
      
      # React アプリケーションにリダイレクト（成功）
      redirect_to "/cosmos?auth_success=true&user_id=#{user.id}"
      
    rescue => e
      Rails.logger.error "Google OAuth Error: #{e.message}"
      redirect_to "/cosmos?auth_error=google_auth_failed"
    end
  end
  
  # 現在のユーザー情報取得
  def me
    if session[:biru_user]
      begin
        user = BiruUser.find(session[:biru_user])
        
        render json: {
          success: true,
          user: {
            id: user.id,
            code: format_employee_code(user.code),  # DBの社員番号を5桁にフォーマット
            name: user.name,
            email: user.email,
            auth_provider: user.auth_provider || 'local'
          }
        }
      rescue ActiveRecord::RecordNotFound
        reset_session
        render json: { error: 'ユーザーが見つかりません' }, status: 404
      end
    else
      render json: { error: 'ログインしていません' }, status: 401
    end
  end
  
  # ログアウト
  def logout
    reset_session
    render json: { success: true, message: 'ログアウトしました' }
  end
  
  # CORS プリフライトリクエスト対応
  def options
    head :ok
  end
  
  # 既存アカウントとGoogle連携
  def link_google
    # 現在ログイン中のユーザーを取得
    current_user = get_current_user
    if current_user.blank?
      render json: { error: 'ログインしていません' }, status: 401
      return
    end
    
    google_id = params[:google_id]
    email = params[:email]
    
    if google_id.blank?
      render json: { error: 'Google IDが必要です' }, status: 400
      return
    end
    
    # 既に他のアカウントで使用されていないかチェック
    existing_user = BiruUser.find_by(google_id: google_id)
    if existing_user && existing_user.id != current_user.id
      render json: { error: 'このGoogleアカウントは既に他のユーザーと連携されています' }, status: 400
      return
    end
    
    # アカウント連携
    current_user.update(
      google_id: google_id,
      email: email
    )
    
    render json: {
      success: true,
      message: 'Googleアカウントと連携しました',
      user: {
        id: current_user.id,
        code: current_user.code,
        name: current_user.name,
        email: current_user.email,
        auth_provider: current_user.auth_provider || 'local'
      }
    }
  end
  
  private
  
  def set_cors_headers
    response.headers['Access-Control-Allow-Origin'] = request.headers['Origin'] || '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, X-Requested-With'
    response.headers['Access-Control-Allow-Credentials'] = 'true'
  end
  
  def save_login_history(user)
    return unless defined?(LoginHistory)
    
    log = LoginHistory.new
    log.biru_user_id = user.id
    log.code = user.code
    log.name = user.name
    log.save!
  rescue => e
    Rails.logger.warn "Failed to save login history: #{e.message}"
  end
  
  def get_current_user
    return nil unless session[:biru_user]
    
    BiruUser.find(session[:biru_user])
  rescue ActiveRecord::RecordNotFound
    reset_session
    nil
  end
  
  # 社員番号の正規化を行いながら認証を試行
  def authenticate_user_with_code_normalization(code, password)
    # パターン1: 入力されたコードをそのまま使用（先頭0保持）
    user = BiruUser.authenticate(code, password)
    return user if user
    
    # パターン2: 数値変換したコード（既存の互換性のため）
    # ただし、先頭が0でない場合や、純粋な数値入力の場合のみ
    if code.match?(/\A\d+\z/) && !code.start_with?('0')
      normalized_code = code.to_i.to_s
      if normalized_code != code
        user = BiruUser.authenticate(normalized_code, password)
        return user if user
      end
    end
    
    # パターン3: 先頭0を削除したコード（レガシー対応）
    if code.start_with?('0') && code.length > 1
      trimmed_code = code.sub(/\A0+/, '')
      user = BiruUser.authenticate(trimmed_code, password)
      return user if user
    end
    
    # 認証失敗
    nil
  end
  
  # 社員番号を5桁にフォーマット（4桁以下の場合は先頭に0を追加）
  def format_employee_code(code)
    return code if code.blank?
    
    # 数値でない場合はそのまま返す
    return code unless code.to_s.match?(/\A\d+\z/)
    
    # 5桁以上の場合はそのまま、4桁以下の場合は先頭に0を追加して5桁にする
    code_str = code.to_s
    if code_str.length <= 4
      code_str.rjust(5, '0')
    else
      code_str
    end
  end
end