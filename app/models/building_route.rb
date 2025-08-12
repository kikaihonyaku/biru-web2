class BuildingRoute < ActiveRecord::Base
  belongs_to :building
  belongs_to :station
end
