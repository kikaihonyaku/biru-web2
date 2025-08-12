class TrustAttackMonthReport < ActiveRecord::Base
  has_many :trust_attack_month_report_actions
  has_many :trust_attack_month_report_ranks
  has_many :trust_attack_month_report_results
  belongs_to :biru_user

  belongs_to :comment_user_updated_user, :class_name => 'BiruUser'
  belongs_to :comment_boss_updated_user, :class_name => 'BiruUser'
end
