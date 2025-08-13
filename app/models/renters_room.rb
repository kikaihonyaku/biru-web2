class RentersRoom < ActiveRecord::Base
  self.table_name = 'biru.renters_rooms'
  belongs_to :renters_building
  has_many :renters_room_pictures
  default_scope { where(delete_flg: false) }
  
end
