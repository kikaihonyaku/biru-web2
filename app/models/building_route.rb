class BuildingRoute < ActiveRecord::Base
  self.table_name = 'biru.building_routes'
  belongs_to :building
  belongs_to :station
end
