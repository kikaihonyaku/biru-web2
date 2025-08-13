class AddCommentToTrustAttackMonthReportResult < ActiveRecord::Migration
  def change
  	add_column :trust_attack_month_report_results, :comment, :string
  	add_column :trust_attack_month_report_results, :comment_updated_at, :datetime
  	add_column :trust_attack_month_report_results, :comment_updated_user, :integer
  end
end
