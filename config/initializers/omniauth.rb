# -*- encoding:utf-8 -*-

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           ENV['GOOGLE_CLIENT_ID'],
           ENV['GOOGLE_CLIENT_SECRET'],
           {
             name: 'google',
             scope: 'email,profile',
             access_type: 'offline',
             prompt: 'consent',
             # Rails アプリケーションの場合、デフォルトのcallback URLは /auth/:provider/callback
             # この場合は /auth/google/callback になる
           }
end

# CSRF保護の設定
OmniAuth.config.allowed_request_methods = [:post, :get]