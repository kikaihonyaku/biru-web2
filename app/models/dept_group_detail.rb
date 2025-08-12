class DeptGroupDetail < ActiveRecord::Base
  belongs_to :dept
  belongs_to :dept_group
end
