class TrustAttackMonthReportResult < ActiveRecord::Base
  self.table_name = 'biru.trust_attack_month_report_results'
  default_scope { where(delete_flg: false) }
  
  belongs_to :trust_attack_month_report    
end
