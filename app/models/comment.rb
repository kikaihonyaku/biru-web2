class Comment < ActiveRecord::Base
  
  default_scope { where(delete_flg: false) }
  belongs_to :biru_user
end
