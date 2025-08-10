class AddDmptnToOwners < ActiveRecord::Migration
  def change
    add_column :owners, :dm_ptn_5, :boolean, :default=>false
    add_column :owners, :dm_ptn_6, :boolean, :default=>false
    add_column :owners, :dm_ptn_7, :boolean, :default=>false
    add_column :owners, :dm_ptn_8, :boolean, :default=>false
  end
end
