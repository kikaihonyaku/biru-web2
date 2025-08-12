class Station < ActiveRecord::Base

  acts_as_gmappable

  belongs_to :line
  has_many :building_nearest_station

  def gmaps4rails_address
   "#{self.address}"
  end

end
