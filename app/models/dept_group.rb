class DeptGroup < ActiveRecord::Base
  self.table_name = 'biru.dept_groups'
  has_many :dept_group_details
end
