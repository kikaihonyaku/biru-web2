class CreateConstructionVendors < ActiveRecord::Migration
  def change
    create_table :construction_vendors do |t|
      t.integer :construction_id
      t.string :construction_code
      t.string :vendor_code
      t.date :construction_scheduled_date # 着工予定日
      t.date :construction_date # 着工日
      t.date :completion_scheduled_date # 完了予定日
      t.integer :updated_biru_user_id
      t.boolean :delete_flg, :default=>false
      t.timestamps
    end
  end
end
