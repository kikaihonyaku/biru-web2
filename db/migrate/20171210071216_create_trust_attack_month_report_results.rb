class CreateTrustAttackMonthReportResults < ActiveRecord::Migration
  def change
    create_table :trust_attack_month_report_results do |t|

      t.integer "trust_attack_month_report_id"
      t.string "trust_apply_code" # 受託申請ID
      t.string "shop_name" # 営業所名
      t.string "apply_type_name" # 申請種別名
      t.string "building_name" # 物件名
      t.integer "yourself_num", :defalut=>0 # 他社戸数
      t.integer "oneself_num", :defalut=>0  # 自社戸数
      t.integer "point", :default=>0  # 受託ポイント
      t.boolean  "delete_flg", :default => false
      t.timestamps
    end
  end
end
