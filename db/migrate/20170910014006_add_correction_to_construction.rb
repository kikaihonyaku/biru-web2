class AddCorrectionToConstruction < ActiveRecord::Migration
  def change
    add_column :constructions, :correction, :integer
  end
end
