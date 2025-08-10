class AddColumnKindTypeToApproachKinds < ActiveRecord::Migration
  def change
    add_column :approach_kinds, :kind_type, :integer
  end
end
