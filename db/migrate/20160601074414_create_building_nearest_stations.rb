class CreateBuildingNearestStations < ActiveRecord::Migration
  def change
    create_table :building_nearest_stations do |t|
      
      t.integer :building_id
      t.integer :row_num
      t.integer :line_id
      t.integer :station_id
      t.boolean :bus_used_flg
      t.integer :minute
      t.boolean :delete_flg, :default=>false
      t.timestamps
    end
  end
end
