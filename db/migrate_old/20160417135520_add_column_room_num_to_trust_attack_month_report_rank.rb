class AddColumnRoomNumToTrustAttackMonthReportRank < ActiveRecord::Migration
  def change
    add_column :trust_attack_month_report_ranks, :room_num, :integer
  end
end
