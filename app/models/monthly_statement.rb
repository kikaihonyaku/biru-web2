class MonthlyStatement < ActiveRecord::Base
  self.table_name = 'biru.monthly_statements'
  belongs_to :item
  belongs_to :dept
end
