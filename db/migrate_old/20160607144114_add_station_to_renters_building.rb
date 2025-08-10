class AddStationToRentersBuilding < ActiveRecord::Migration
  def change
    # building
    add_column :renters_buildings, :access_a_line_code, :string
    add_column :renters_buildings, :access_a_line_name, :string
    add_column :renters_buildings, :access_a_station_code, :string
    add_column :renters_buildings, :access_a_station_name, :string

    add_column :renters_buildings, :access_b_line_code, :string
    add_column :renters_buildings, :access_b_line_name, :string
    add_column :renters_buildings, :access_b_station_code, :string
    add_column :renters_buildings, :access_b_station_name, :string

    add_column :renters_buildings, :access_c_line_code, :string
    add_column :renters_buildings, :access_c_line_name, :string
    add_column :renters_buildings, :access_c_station_code, :string
    add_column :renters_buildings, :access_c_station_name, :string

    add_column :renters_buildings, :access_d_line_code, :string
    add_column :renters_buildings, :access_d_line_name, :string
    add_column :renters_buildings, :access_d_station_code, :string
    add_column :renters_buildings, :access_d_station_name, :string
  end
end
