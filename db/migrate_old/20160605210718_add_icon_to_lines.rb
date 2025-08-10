class AddIconToLines < ActiveRecord::Migration
  def change
    add_column :lines, :icon, :string
  end
end
