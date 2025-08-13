class ApplicationRecord < ActiveRecord::Base
  self.table_name = 'biru.application_records'
  primary_abstract_class
  
  # SQL Serverのデフォルトスキーマを設定
  def self.connection
    super.tap do |conn|
      conn.execute("SET SCHEMA biru") if conn.adapter_name.downcase == 'sqlserver'
    end
  end
end
