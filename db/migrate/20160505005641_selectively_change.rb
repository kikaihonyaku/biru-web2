class SelectivelyChange < ActiveRecord::Migration
  def change
    add_column :selectively_postcodes, :selective_type, :integer
    add_column :selectively_postcodes, :address, :string
    add_column :selectively_postcodes, :station_name, :string

    remove_column :buildings, :selectively_flg
    add_column :buildings, :selective_type, :integer, :default=>0
  end

end
