class SelectivelyPostcode < ActiveRecord::Base
  # attr_accessible :title, :body
  default_scope where(:delete_flg => false)
end
