class TrustAttackMonthReportAction < ActiveRecord::Base
  
  self.table_name = 'biru.trust_attack_month_report_actions'
  default_scope { where(delete_flg: false) }
  
  belongs_to :owner
  belongs_to :approach_kind
  belongs_to :trust_attack_month_report
  belongs_to :owner_approach
  
end
