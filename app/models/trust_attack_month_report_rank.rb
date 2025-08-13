class TrustAttackMonthReportRank < ActiveRecord::Base

  self.table_name = 'biru.trust_attack_month_report_ranks'
  default_scope { where(delete_flg: false) }

  belongs_to :attack_state_last_month, :class_name => 'AttackState'
  belongs_to :attack_state_this_month, :class_name => 'AttackState'
  belongs_to :building
  belongs_to :owner
  belongs_to :trust_attack_month_report

end
