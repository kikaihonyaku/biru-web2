class CreateConstructionApproaches < ActiveRecord::Migration
  def change
    create_table :construction_approaches do |t|
      t.integer :construction_id
      t.date :approach_date
      t.integer :approach_kind_id
      t.text :content
      t.integer :biru_user_id
      t.boolean :delete_flg, :default=>false
      t.timestamps
    end
  end
end
