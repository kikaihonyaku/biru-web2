class BuildingNearestStation < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :building
  belongs_to :station
  belongs_to :line
  default_scope where(:delete_flg => false)
end
