class AddApproachCntRankToTrustAttackMonthReports < ActiveRecord::Migration
  def change
    add_column :trust_attack_month_reports, :approach_cnt_s, :integer, :default=>0
    add_column :trust_attack_month_reports, :approach_cnt_a, :integer, :default=>0
    add_column :trust_attack_month_reports, :approach_cnt_b, :integer, :default=>0
    add_column :trust_attack_month_reports, :approach_cnt_c, :integer, :default=>0
    add_column :trust_attack_month_reports, :approach_cnt_z, :integer, :default=>0
  end
end
