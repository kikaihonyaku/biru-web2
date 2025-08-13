class RentersBuilding < ActiveRecord::Base
  self.table_name = 'biru.renters_buildings'
  has_many :renters_rooms
  
  default_scope { where(delete_flg: false) }
  
end
