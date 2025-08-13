class RentersReport < ActiveRecord::Base
  
  self.table_name = 'biru.renters_reports'
  belongs_to :renters_room
  belongs_to :renters_building
  

  default_scope { where(delete_flg: false) }

end
