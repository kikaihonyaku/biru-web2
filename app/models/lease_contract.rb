class LeaseContract < ActiveRecord::Base
  self.table_name = 'biru.lease_contracts'
  belongs_to :building
  belongs_to :room
end
