class TrustMaintenance < ActiveRecord::Base
  
  belongs_to :trust
  default_scope { where(delete_flg: false) }
  
  
end
