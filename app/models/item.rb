class Item < ActiveRecord::Base
  self.table_name = 'biru.items'
  has_many :monthly_statements
end
