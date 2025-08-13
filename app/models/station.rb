class Station < ActiveRecord::Base

  self.table_name = 'biru.stations'
  acts_as_gmappable

  belongs_to :line
  has_many :building_nearest_station

  def gmaps4rails_address
   "#{self.address}"
  end

end
