class DataUpdateTime < ActiveRecord::Base
  self.table_name = 'biru.data_update_times'
  belongs_to :biru_user
end
