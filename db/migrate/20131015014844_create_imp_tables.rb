class CreateImpTables < ActiveRecord::Migration
  def change

    # Žæ‚èž‚Ýƒe[ƒuƒ‹
    create_table "imp_tables", :force => true do |t|
      t.string "siten_cd"
      t.string "eigyo_order"
      t.string "eigyo_cd"
      t.string  "eigyo_nm"
      t.string "manage_type_cd"
      t.string "manage_type_nm"
      t.string "trust_cd"
      t.string "building_cd"
      t.string  "building_nm"
      t.string "building_type_cd"
      t.string "building_address"
      t.string "room_cd"
      t.string  "room_nm"
      t.string  "kanri_start_date"
      t.string  "kanri_end_date"
      t.string "room_aki"
      t.string  "room_type_cd"
      t.string  "room_type_nm"
      t.string  "room_layout_cd"
      t.string  "room_layout_nm"
      t.string "owner_cd"
      t.string  "owner_nm"
      t.string  "owner_kana"
      t.string  "owner_address"
      t.string  "owner_tel"
    end

  end

end
