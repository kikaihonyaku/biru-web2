class MonthlyStatement < ActiveRecord::Base
  belongs_to :item
  belongs_to :dept
end
