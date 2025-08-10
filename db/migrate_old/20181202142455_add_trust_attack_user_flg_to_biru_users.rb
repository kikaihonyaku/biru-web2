class AddTrustAttackUserFlgToBiruUsers < ActiveRecord::Migration
  def change
    add_column :biru_users, :trust_attack_user_flg, :boolean, :default=>false
    add_column :biru_users, :trust_attack_area_name, :string
    #add_column :biru_users, :trust_attack_sort_num, :integer
  end
end
