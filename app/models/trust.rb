# -*- encoding:utf-8 -*-
class Trust < ActiveRecord::Base
  belongs_to :building
  belongs_to :owner
  belongs_to :manage_type
  belongs_to :biru_user
  belongs_to :attack_state


  # デフォルトスコープを定義
  default_scope { where(delete_flg: false) } 
  
end
