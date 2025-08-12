class RentersRoomPicture < ActiveRecord::Base
  
  default_scope { where(delete_flg: false) }
  
  belongs_to :renters_room
end
