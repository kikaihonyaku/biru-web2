class ConstructionVendor < ActiveRecord::Base
  self.table_name = 'biru.construction_vendors'
  belongs_to :construction
  default_scope { where(delete_flg: false) }
end
