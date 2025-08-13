class Comment < ActiveRecord::Base
  
  self.table_name = 'biru.comments'
  default_scope { where(delete_flg: false) }
  belongs_to :biru_user
end
