class SelectivelyPostcode < ActiveRecord::Base
  default_scope { where(delete_flg: false) }
end
