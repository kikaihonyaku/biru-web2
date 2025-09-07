class BiruUser < ActiveRecord::Base
  
  self.table_name = 'biru.biru_users'
  
  def self.authenticate(code, password)
    where(:code=> code,
      :password => password).first
      #:password => Digest::SHA1.hexdigest(password)).first
  end
  
  # Google OAuth認証関連メソッド
  def self.find_or_create_by_google(omniauth_data)
    # GoogleのユニークIDで既存ユーザーを検索
    user = find_by(google_id: omniauth_data['uid'])
    
    if user
      # 既存のGoogleアカウント連携ユーザーの場合
      user.update(
        email: omniauth_data['info']['email']
      )
      return user
    end
    
    # メールアドレスで既存ユーザーを検索（アカウント連携用）
    email = omniauth_data['info']['email']
    user = find_by(email: email) if email.present?
    
    if user && user.google_id.blank?
      # 既存ユーザーにGoogleアカウントを連携
      user.update(
        google_id: omniauth_data['uid'],
        auth_provider: 'google',
        email: email
      )
      return user
    end
    
    # 新規ユーザー作成（Google認証のみ）
    create!(
      google_id: omniauth_data['uid'],
      auth_provider: 'google',
      email: omniauth_data['info']['email'],
      name: omniauth_data['info']['name'] || omniauth_data['info']['email'],
      code: generate_unique_code
    )
  end
  
  def google_authenticated?
    google_id.present? && auth_provider == 'google'
  end
  
  private
  
  def self.generate_unique_code
    # Google認証ユーザー用のユニークなコードを生成
    loop do
      code = "G#{SecureRandom.alphanumeric(8).upcase}"
      break code unless exists?(code: code)
    end
  end
    
end
