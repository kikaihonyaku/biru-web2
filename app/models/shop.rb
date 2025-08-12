# -*- encoding :utf-8 -*-
class Shop < ActiveRecord::Base
  acts_as_gmappable
  
  default_scope { where(delete_flg: false) }

  def gmaps4rails_address
   "#{self.address}"
  end
end
