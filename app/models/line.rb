class Line < ActiveRecord::Base
  self.table_name = 'biru.lines'
  has_many :stations
  has_many :building_nearest_station
end
