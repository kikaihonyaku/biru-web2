class CreateMailReactions < ActiveRecord::Migration
  def change
    create_table :mail_reactions do |t|

      t.timestamps
    end
  end
end
