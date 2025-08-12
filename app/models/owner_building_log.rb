class OwnerBuildingLog < ActiveRecord::Base
  
  belongs_to :owner
  belongs_to :building
  belongs_to :trust
  belongs_to :biru_user
  
end
