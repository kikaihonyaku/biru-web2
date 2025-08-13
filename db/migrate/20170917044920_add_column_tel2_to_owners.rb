class AddColumnTel2ToOwners < ActiveRecord::Migration
  def change
    add_column :owners, :tel2, :string
    add_column :imp_tables, :owner_tel2, :string
  end
end
