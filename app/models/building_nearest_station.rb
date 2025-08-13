class BuildingNearestStation < ActiveRecord::Base
  self.table_name = 'biru.building_nearest_stations'
  belongs_to :building
  belongs_to :station
  belongs_to :line
  default_scope { where(delete_flg: false) }
end
