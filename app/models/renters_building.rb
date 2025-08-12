class RentersBuilding < ActiveRecord::Base
  has_many :renters_rooms
  
  default_scope { where(delete_flg: false) }
  
end
