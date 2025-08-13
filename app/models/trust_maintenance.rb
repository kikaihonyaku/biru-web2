class TrustMaintenance < ActiveRecord::Base
  
  self.table_name = 'biru.trust_maintenances'
  belongs_to :trust
  default_scope { where(delete_flg: false) }
  
  
end
