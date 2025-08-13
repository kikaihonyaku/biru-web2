class AddDmToTelCntBothToTrustAttackMonthReports < ActiveRecord::Migration
  def change
  	add_column :trust_attack_month_reports, :dm_to_tel_result_both, :integer
  end
end
