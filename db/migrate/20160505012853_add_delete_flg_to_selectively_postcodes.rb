class AddDeleteFlgToSelectivelyPostcodes < ActiveRecord::Migration
  def change
    add_column :selectively_postcodes, :delete_flg, :boolean, :default=>false
  end
end
