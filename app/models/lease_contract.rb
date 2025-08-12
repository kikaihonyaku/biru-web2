class LeaseContract < ActiveRecord::Base
  belongs_to :building
  belongs_to :room
end
