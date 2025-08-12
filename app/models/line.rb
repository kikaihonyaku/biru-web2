class Line < ActiveRecord::Base
  has_many :stations
  has_many :building_nearest_station
end
