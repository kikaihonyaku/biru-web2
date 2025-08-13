class OwnerBuildingLog < ActiveRecord::Base
  
  self.table_name = 'biru.owner_building_logs'
  belongs_to :owner
  belongs_to :building
  belongs_to :trust
  belongs_to :biru_user
  
end
