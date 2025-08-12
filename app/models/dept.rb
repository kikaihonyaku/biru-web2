class Dept < ActiveRecord::Base
  has_many :dept_group_details
  has_many :monthly_statements
end
