class BiruUserMonthly < ActiveRecord::Base
  self.table_name = 'biru.biru_user_monthlies'
  belongs_to :biru_user
end
