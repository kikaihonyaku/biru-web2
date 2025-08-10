# -*- encoding :utf-8 -*-
class Shop < ActiveRecord::Base
  acts_as_gmappable
  # attr_accessible :title, :body
  attr_accessible :name, :address, :icon, :code
  
  default_scope where(:delete_flg => false)

  def gmaps4rails_address
   "#{self.address}"
  end
end
