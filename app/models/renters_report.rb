class RentersReport < ActiveRecord::Base
  
  belongs_to :renters_room
  belongs_to :renters_building
  

  default_scope { where(delete_flg: false) }

end
