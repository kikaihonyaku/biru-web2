class AddColumnWorkRentersRoomAccess < ActiveRecord::Migration
  def change
    add_column :work_renters_rooms, :access_a_line_code, :string
    add_column :work_renters_rooms, :access_a_line_name, :string
    add_column :work_renters_rooms, :access_a_station_code, :string
    add_column :work_renters_rooms, :access_a_station_name, :string

    add_column :work_renters_rooms, :access_b_line_code, :string
    add_column :work_renters_rooms, :access_b_line_name, :string
    add_column :work_renters_rooms, :access_b_station_code, :string
    add_column :work_renters_rooms, :access_b_station_name, :string

    add_column :work_renters_rooms, :access_c_line_code, :string
    add_column :work_renters_rooms, :access_c_line_name, :string
    add_column :work_renters_rooms, :access_c_station_code, :string
    add_column :work_renters_rooms, :access_c_station_name, :string

    add_column :work_renters_rooms, :access_d_line_code, :string
    add_column :work_renters_rooms, :access_d_line_name, :string
    add_column :work_renters_rooms, :access_d_station_code, :string
    add_column :work_renters_rooms, :access_d_station_name, :string
    

  end
end
