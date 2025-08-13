class Document < ActiveRecord::Base
  
  self.table_name = 'biru.documents'
  belongs_to :owner
  belongs_to :building
  belongs_to :biru_user
  

  # 2015.08.20 paper_clip
  # has_attached_file :doc_file, style: { medium: "300x300>", thumb: "100x100>" }
  # validates_attachment :doc_file, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] }
end
