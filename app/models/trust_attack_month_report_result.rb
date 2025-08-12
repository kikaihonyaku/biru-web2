class TrustAttackMonthReportResult < ActiveRecord::Base
  default_scope { where(delete_flg: false) }
  
  belongs_to :trust_attack_month_report    
end
