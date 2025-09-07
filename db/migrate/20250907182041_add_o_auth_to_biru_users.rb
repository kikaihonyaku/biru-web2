class AddOAuthToBiruUsers < ActiveRecord::Migration[8.0]
  def up
    # SQL Serverのスキーマを明示的に指定
    add_column :'biru.biru_users', :google_id, :string
    add_column :'biru.biru_users', :auth_provider, :string, default: 'local'
    add_column :'biru.biru_users', :email, :string
    
    # インデックスはSQL文で直接実行
    execute "CREATE INDEX IX_biru_users_google_id ON biru.biru_users (google_id)"
    execute "CREATE INDEX IX_biru_users_email ON biru.biru_users (email)"
  end
  
  def down
    execute "DROP INDEX IX_biru_users_google_id ON biru.biru_users"
    execute "DROP INDEX IX_biru_users_email ON biru.biru_users"
    
    remove_column :'biru.biru_users', :google_id
    remove_column :'biru.biru_users', :auth_provider
    remove_column :'biru.biru_users', :email
  end
end
