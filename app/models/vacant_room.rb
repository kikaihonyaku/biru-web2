class VacantRoom < ActiveRecord::Base
  self.table_name = 'biru.vacant_rooms'
  belongs_to :building
  belongs_to :room_layout
  belongs_to :manage_type
  belongs_to :shop
  belongs_to :room
end
