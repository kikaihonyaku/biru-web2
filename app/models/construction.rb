class Construction < ActiveRecord::Base
  attr_accessible :completion_check_date, :completion_check_expected_date, :completion_check_user_id, :correction
  has_many :construction_approaches
end
