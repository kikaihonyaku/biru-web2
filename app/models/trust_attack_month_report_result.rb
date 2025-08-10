class TrustAttackMonthReportResult < ActiveRecord::Base
  # attr_accessible :title, :body
  default_scope where(:delete_flg => false)
  
  belongs_to :trust_attack_month_report    
end
