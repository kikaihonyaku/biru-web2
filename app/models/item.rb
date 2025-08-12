class Item < ActiveRecord::Base
  has_many :monthly_statements
end
