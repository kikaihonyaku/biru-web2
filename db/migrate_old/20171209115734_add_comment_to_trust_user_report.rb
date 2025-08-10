class AddCommentToTrustUserReport < ActiveRecord::Migration
  def change
    add_column :trust_attack_month_reports, :comment_user_could, :text
    add_column :trust_attack_month_reports, :comment_user_not_could, :text
    add_column :trust_attack_month_reports, :comment_user_plan, :text
    add_column :trust_attack_month_reports, :comment_user_updated_user_id, :integer
    add_column :trust_attack_month_reports, :comment_user_updated_at, :datetime

    add_column :trust_attack_month_reports, :comment_boss_could, :text
    add_column :trust_attack_month_reports, :comment_boss_not_could, :text
    add_column :trust_attack_month_reports, :comment_boss_plan, :text
    add_column :trust_attack_month_reports, :comment_boss_updated_user_id, :integer
    add_column :trust_attack_month_reports, :comment_boss_updated_at, :datetime

    add_column :trust_attack_month_reports, :apply_yourself_num, :integer
    add_column :trust_attack_month_reports, :apply_oneself_num, :integer
    add_column :trust_attack_month_reports, :apply_point, :integer

  end
end
