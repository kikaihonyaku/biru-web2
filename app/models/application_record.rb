class ApplicationRecord < ActiveRecord::Base
  self.table_name = 'biru.application_records'
  primary_abstract_class
end
