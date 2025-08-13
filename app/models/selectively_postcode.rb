class SelectivelyPostcode < ActiveRecord::Base
  self.table_name = 'biru.selectively_postcodes'
  default_scope { where(delete_flg: false) }
end
