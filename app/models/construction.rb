class Construction < ActiveRecord::Base
  self.table_name = 'biru.constructions'
  has_many :construction_approaches
end
