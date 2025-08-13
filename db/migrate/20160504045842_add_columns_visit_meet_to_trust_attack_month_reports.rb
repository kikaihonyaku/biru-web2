class AddColumnsVisitMeetToTrustAttackMonthReports < ActiveRecord::Migration
  def change
    add_column :trust_attack_month_reports, :visit_meet_plan, :integer
    add_column :trust_attack_month_reports, :visit_meet_par, :float
  end
end
