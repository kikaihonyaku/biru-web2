class DeptGroup < ActiveRecord::Base
  has_many :dept_group_details
end
