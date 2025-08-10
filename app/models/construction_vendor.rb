class ConstructionVendor < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :construction
  default_scope where(:delete_flg => false)
end
