class BuildingNearestStation < ActiveRecord::Base
  belongs_to :building
  belongs_to :station
  belongs_to :line
  default_scope { where(delete_flg: false) }
end
