class RentersRoomPicture < ActiveRecord::Base
  
  self.table_name = 'biru.renters_room_pictures'
  default_scope { where(delete_flg: false) }
  
  belongs_to :renters_room
end
