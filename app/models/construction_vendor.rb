class ConstructionVendor < ActiveRecord::Base
  belongs_to :construction
  default_scope { where(delete_flg: false) }
end
