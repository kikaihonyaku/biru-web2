class CreateMarketBuildings < ActiveRecord::Migration
  def change
    create_table :market_buildings do |t|

      t.string   "name"
      t.string   "address"
      t.float    "latitude"
      t.float    "longitude"
      t.boolean  "gmaps"
      t.integer  "shop_id"
      t.integer  "build_type_id"
      t.integer  "room_num"
      t.text     "memo"
      t.boolean  "delete_flg",           :default => false

      t.string   "postcode"


      t.timestamps
    end
  end
end
