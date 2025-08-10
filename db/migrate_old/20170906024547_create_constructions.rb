class CreateConstructions < ActiveRecord::Migration
  def change
    create_table :constructions do |t|
      t.string :code
      t.integer :completion_check_user_id
      t.date :completion_check_expected_date
      t.date :completion_check_date

      t.timestamps
    end
  end
end
