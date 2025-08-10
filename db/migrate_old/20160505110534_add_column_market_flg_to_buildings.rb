class AddColumnMarketFlgToBuildings < ActiveRecord::Migration
  def change
    add_column :buildings, :market_flg, :boolean, :default=>false
  end
end
