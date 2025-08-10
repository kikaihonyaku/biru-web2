#-*- coding:utf-8 -*-

class ConstructionApproach < ActiveRecord::Base
  attr_accessible :approach_date, :approach_kind_id, :biru_user_id, :construction_id, :content, :delete_flg
  belongs_to :construction
  belongs_to :approach_kind

  belongs_to :biru_user
  validates :content, :presence => {:message =>'内容を入力してください'}
  
  default_scope where(:delete_flg => false)
  
end
