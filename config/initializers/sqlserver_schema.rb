# SQL Serverのデフォルトスキーマを設定
Rails.application.config.after_initialize do
  ActiveRecord::Base.connection.execute("USE BIRU30_DEV") if Rails.env.development?
  ActiveRecord::Base.connection.execute("USE BIRU30_TEST") if Rails.env.test?
  ActiveRecord::Base.connection.execute("USE BIRU30") if Rails.env.production?
  
  # デフォルトスキーマを設定
  ActiveRecord::Base.connection.execute("SET SCHEMA biru")
rescue => e
  Rails.logger.warn "Failed to set default schema: #{e.message}"
end
