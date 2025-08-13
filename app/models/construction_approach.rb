#-*- coding:utf-8 -*-

class ConstructionApproach < ActiveRecord::Base
  self.table_name = 'biru.construction_approaches'
  belongs_to :construction
  belongs_to :approach_kind

  belongs_to :biru_user
  validates :content, :presence => {:message =>'内容を入力してください'}
  
  default_scope { where(delete_flg: false) }
  
end
