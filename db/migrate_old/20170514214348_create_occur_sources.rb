class CreateOccurSources < ActiveRecord::Migration
  def change
    create_table :occur_sources do |t|
      t.string :code
      t.string :name
      t.timestamps
    end

    add_column :buildings, :occur_source_id, :integer
   
  end
end
