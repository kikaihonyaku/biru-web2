class Dept < ActiveRecord::Base
  self.table_name = 'biru.depts'
  has_many :dept_group_details
  has_many :monthly_statements
end
