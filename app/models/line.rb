class Line < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :code, :name
  has_many :stations
  has_many :building_nearest_station
end
