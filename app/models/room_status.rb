class RoomStatus < ActiveRecord::Base
  self.table_name = 'biru.room_statuses'
  has_many :rooms
end
