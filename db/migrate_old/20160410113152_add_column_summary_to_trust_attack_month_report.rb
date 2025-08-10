class AddColumnSummaryToTrustAttackMonthReport < ActiveRecord::Migration
  def change
    add_column :trust_attack_month_reports, :area_name, :string
    add_column :trust_attack_month_reports, :dm_to_tel_plan, :integer
    add_column :trust_attack_month_reports, :dm_to_tel_result, :integer
    add_column :trust_attack_month_reports, :dm_to_tel_average, :float
    
  end
end
