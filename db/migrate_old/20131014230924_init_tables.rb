class InitTables < ActiveRecord::Migration
  def change
    ###########################
    # �}�X�^�e�[�u��
    ###########################

    # ������ʃ}�X�^
    create_table "build_types", :force => true do |t|
      t.string   "code"
      t.string   "name"
      t.string   "icon"
    end

    # �Ԏ��}�X�^
    create_table "room_layouts", :force => true do |t|
      t.string "code"
      t.string "name"
    end

    # ������ʃ}�X�^
    create_table "room_types", :force => true do |t|
      t.string "code"
      t.string "name"
    end
    
    # �Ǘ������}�X�^
    create_table "manage_types", :force => true do |t|
      t.string   "code"
      t.string   "name"
      t.string   "icon"
      t.string   "line_color"
    end

    # �c�Ə��}�X�^
    create_table "shops", :force => true do |t|
      t.string   "code"
      t.string   "name"
      t.string   "address"
      t.float    "latitude"
      t.float    "longitude"
      t.boolean  "gmaps"
      t.string   "icon"
      t.integer  "area_id"
      t.integer  "group_id"
    end

    add_index "shops", ["area_id"], :name => "index_shops_on_area_id"
    add_index "shops", ["group_id"], :name => "index_shops_on_group_id"

    
    ###########################
    # �g�����U�N�V�����e�[�u��
    ###########################

    # �ݎ���
    create_table "owners", :force => true do |t|
      t.string   "code"
      t.string   "name"
      t.string   "kana"
      t.string   "address"
      t.float    "latitude"
      t.float    "longitude"
      t.boolean  "gmaps"
      t.datetime "created_at",                       :null => false
      t.datetime "updated_at",                       :null => false
      t.text     "memo"
      t.integer  "owner_rank_id"
      t.boolean  "delete_flg",    :default => false
      t.string   "attack_code"
    end

    # �Ǘ��ϑ��_����
    create_table "trusts", :force => true do |t|
      t.integer  "owner_id"
      t.integer  "building_id"
      t.integer  "manage_type_id"
      t.string   "code"
      t.datetime "created_at",                        :null => false
      t.datetime "updated_at",                        :null => false
      t.boolean  "delete_flg",     :default => false
    end

    add_index "trusts", ["building_id"], :name => "index_trusts_on_building_id"
    add_index "trusts", ["manage_type_id"], :name => "index_trusts_on_manage_type_id"
    add_index "trusts", ["owner_id"], :name => "index_trusts_on_owner_id"


    # �������
    create_table "buildings", :force => true do |t|
      t.string   "code"
      t.string   "attack_code"
      t.string   "name"
      t.string   "address"
      t.float    "latitude"
      t.float    "longitude"
      t.boolean  "gmaps"
      t.integer  "shop_id"
      t.integer  "build_type_id"
      t.integer  "room_num"
      t.string "tmp_build_type_icon"
      t.string "tmp_manage_type_icon"
      t.text     "memo"
      t.boolean  "delete_flg", :default => false
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    add_index "buildings", ["build_type_id"], :name => "index_buildings_on_build_type_id"
    add_index "buildings", ["shop_id"], :name => "index_buildings_on_shop_id"

    # �������
    create_table "rooms", :force => true do |t|
      t.integer "building_cd"
      t.string  "code"
      t.string  "name"
      t.integer "room_type_id"
      t.integer "room_layout_id"
      t.integer "trust_id"
      t.integer "manage_type_id"
      t.integer "building_id"
      t.integer "rent"
      t.boolean "delete_flg",     :default => false
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end
  end

end
