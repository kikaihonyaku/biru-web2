class AddCommentToConstructionVendors < ActiveRecord::Migration
  def change
    add_column :construction_vendors, :comment, :text
  end
end
