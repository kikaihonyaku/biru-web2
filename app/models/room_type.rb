class RoomType < ActiveRecord::Base
  self.table_name = 'biru.room_types'
  has_many :rooms
end
