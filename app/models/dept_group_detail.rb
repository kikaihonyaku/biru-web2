class DeptGroupDetail < ActiveRecord::Base
  self.table_name = 'biru.dept_group_details'
  belongs_to :dept
  belongs_to :dept_group
end
