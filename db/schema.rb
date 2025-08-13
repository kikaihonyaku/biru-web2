# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2018_12_02_142455) do
  create_table "W_SUUMO", primary_key: "ID", force: :cascade do |t|
    t.integer "営業所CD"
    t.integer "ROWNO"
    t.string "ネット", limit: 2
    t.string "転載", limit: 2
    t.string "会社間", limit: 2
    t.string "おすすめピックアップ", limit: 2
    t.string "動画", limit: 2
    t.string "ハイライト", limit: 2
    t.string "ホームページサービス", limit: 2
    t.string "見学予約", limit: 2
    t.string "沿線", limit: 20
    t.string "駅", limit: 20
    t.string "交通", limit: 20
    t.string "沿線2", limit: 20
    t.string "駅2", limit: 20
    t.string "交通2", limit: 20
    t.string "沿線3", limit: 20
    t.string "駅3", limit: 20
    t.string "交通3", limit: 20
    t.string "物件名", limit: 20
    t.string "部屋番号", limit: 20
    t.string "間取", limit: 20
    t.string "専有面積", limit: 10
    t.string "空室初回掲載時賃料", limit: 10
    t.string "現在賃料", limit: 10
    t.string "坪賃料", limit: 10
    t.string "管理費", limit: 10
    t.string "管理費込み坪賃料", limit: 10
    t.string "礼金", limit: 2
    t.string "敷金", limit: 2
    t.string "償却金", limit: 2
    t.string "保証金", limit: 2
    t.string "敷引", limit: 2
    t.string "竣工年月", limit: 10
    t.string "入居", limit: 10
    t.string "取引態様", limit: 10
    t.string "星マーク", limit: 2
    t.string "オーナー名", limit: 20
    t.string "向き", limit: 10
    t.string "物件所在地", limit: 200
    t.string "構造", limit: 10
    t.string "階建", limit: 10
    t.string "貴社物件コード", limit: 10
    t.string "設備･条件", limit: 256
    t.string "ネット用キャッチ", limit: 256
    t.string "ネット用コメント", limit: 256
    t.string "備考", limit: 1024
    t.string "貴社間取図", limit: 10
    t.string "R_間取図", limit: 10
    t.string "外観", limit: 10
    t.string "キッチン", limit: 10
    t.string "リビング居室", limit: 10
    t.string "バス", limit: 10
    t.string "画像点数", limit: 10
    t.string "内観", limit: 10
    t.string "ネット基本画像1", limit: 10
    t.string "ネット基本画像2", limit: 10
    t.string "ネット基本画像3", limit: 10
    t.string "転載_指示", limit: 10
    t.string "転載_実掲載", limit: 10
    t.string "HPサービス掲載", limit: 10
    t.string "初回掲載日", limit: 10
    t.string "本日までの経過日数", limit: 10
    t.string "SUUMO3月間_掲載日数", limit: 10
    t.string "SUUMO3月間_一覧_合計", limit: 10
    t.string "SUUMO3月間_一覧_1日あたり", limit: 10
    t.string "SUUMO3月間_詳細_合計", limit: 10
    t.string "SUUMO3月間_詳細_1日あたり", limit: 10
    t.string "SUUMO3月間_詳細一覧の割合", limit: 10
    t.string "SUUMO3月間_見学予約問合せ", limit: 10
    t.string "SUUMO3月間_問合せ―見学予約含", limit: 10
    t.string "SUUMO指定期間_掲載日数", limit: 10
    t.string "SUUMO指定期間_一覧_合計", limit: 10
    t.string "SUUMO指定期間_一覧_1日あたり", limit: 10
    t.string "SUUMO指定期間_詳細_合計", limit: 10
    t.string "SUUMO指定期間_詳細_1日あたり", limit: 10
    t.string "SUUMO指定期間_詳細一覧の割合", limit: 10
    t.string "SUUMO指定期間_見学予約問合せ", limit: 10
    t.string "SUUMO指定期間_問合せ見学予約含", limit: 10
    t.string "会社間3月間_掲載日数", limit: 10
    t.string "会社間3月間_一覧", limit: 10
    t.string "会社間3月間_詳細", limit: 10
    t.string "会社間3月間_募集画面", limit: 10
    t.string "会社間3月間_印刷画面", limit: 10
    t.string "会社間指定期間_掲載日数", limit: 10
    t.string "会社間指定期間_一覧", limit: 10
    t.string "会社間指定期間_詳細", limit: 10
    t.string "会社間指定期間_募集画面", limit: 10
    t.string "会社間指定期間_印刷画面", limit: 10
    t.string "集計_開始日", limit: 10
    t.string "集計_終了日", limit: 10
    t.datetime "取込日時"
  end

  create_table "approach_kinds", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.integer "sequence"
    t.integer "kind_type"
  end

  create_table "attack_states", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.integer "disp_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "icon"
    t.integer "score"
  end

  create_table "biru_user_monthlies", force: :cascade do |t|
    t.integer "biru_user_id"
    t.string "month"
    t.integer "trust_plan_visit"
    t.integer "trust_plan_dm"
    t.integer "trust_plan_tel"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "trust_plan_contract"
    t.integer "trust_plan_suggestion"
    t.index ["biru_user_id"], name: "index_biru_user_monthlies_on_biru_user_id"
  end

  create_table "biru_users", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "attack_all_search", default: false
    t.string "syain_id"
    t.boolean "trust_attack_user_flg", default: false
    t.string "trust_attack_area_name"
    t.integer "trust_attack_sort_num"
  end

  create_table "build_types", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "icon"
  end

  create_table "building_nearest_stations", force: :cascade do |t|
    t.integer "building_id"
    t.integer "row_num"
    t.integer "line_id"
    t.integer "station_id"
    t.boolean "bus_used_flg"
    t.integer "minute"
    t.boolean "delete_flg", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "building_routes", force: :cascade do |t|
    t.integer "building_id"
    t.string "code"
    t.integer "station_id"
    t.boolean "bus", default: false
    t.integer "minutes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["building_id"], name: "index_building_routes_on_building_id"
    t.index ["station_id"], name: "index_building_routes_on_station_id"
  end

  create_table "buildings", force: :cascade do |t|
    t.string "code"
    t.string "attack_code"
    t.string "name"
    t.string "address"
    t.real "latitude"
    t.real "longitude"
    t.boolean "gmaps"
    t.integer "shop_id"
    t.integer "build_type_id"
    t.integer "room_num"
    t.string "tmp_build_type_icon"
    t.string "tmp_manage_type_icon"
    t.text "memo"
    t.boolean "delete_flg", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "kanri_room_num", default: 0
    t.integer "free_num", default: 0
    t.integer "owner_stop_num", default: 0
    t.integer "biru_age", default: 0
    t.string "build_day"
    t.integer "biru_user_id"
    t.string "hash_key"
    t.string "proprietary_company"
    t.boolean "neighborhood_flg", default: false
    t.boolean "room_all_flg", default: false
    t.string "postcode"
    t.integer "selective_type", default: 0
    t.boolean "market_flg", default: false
    t.integer "occur_source_id"
    t.index ["attack_code"], name: "index_buildings_on_attack_code"
    t.index ["biru_user_id"], name: "index_buildings_on_biru_user_id"
    t.index ["build_type_id"], name: "index_buildings_on_build_type_id"
    t.index ["code"], name: "index_buildings_on_code"
    t.index ["name"], name: "index_buildings_on_name"
    t.index ["shop_id"], name: "index_buildings_on_shop_id"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "comment_type"
    t.string "code"
    t.string "sub_code"
    t.text "content"
    t.integer "biru_user_id"
    t.boolean "delete_flg", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "construction_approaches", force: :cascade do |t|
    t.integer "construction_id"
    t.date "approach_date"
    t.integer "approach_kind_id"
    t.text "content"
    t.integer "biru_user_id"
    t.boolean "delete_flg", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "construction_vendors", force: :cascade do |t|
    t.integer "construction_id"
    t.string "construction_code"
    t.string "vendor_code"
    t.date "construction_scheduled_date"
    t.date "construction_date"
    t.date "completion_scheduled_date"
    t.integer "updated_biru_user_id"
    t.boolean "delete_flg", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "comment"
  end

  create_table "constructions", force: :cascade do |t|
    t.string "code"
    t.integer "completion_check_user_id"
    t.date "completion_check_expected_date"
    t.date "completion_check_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "correction"
  end

  create_table "data_update_times", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "start_datetime"
    t.datetime "update_datetime"
    t.integer "biru_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "next_start_date"
    t.index ["biru_user_id"], name: "index_data_update_times_on_biru_user_id"
  end

  create_table "dept_group_details", force: :cascade do |t|
    t.integer "dept_group_id"
    t.integer "dept_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dept_group_id"], name: "index_dept_group_details_on_dept_group_id"
    t.index ["dept_id"], name: "index_dept_group_details_on_dept_id"
  end

  create_table "dept_groups", force: :cascade do |t|
    t.string "busyo_id"
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["busyo_id"], name: "index_dept_groups_on_busyo_id"
  end

  create_table "depts", force: :cascade do |t|
    t.string "busyo_id"
    t.string "code"
    t.string "name"
    t.boolean "delete_flg", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sort_num"
    t.index ["busyo_id"], name: "index_depts_on_busyo_id"
  end

  create_table "documents", force: :cascade do |t|
    t.integer "owner_id"
    t.integer "building_id"
    t.string "file_name"
    t.integer "biru_user_id"
    t.boolean "delete_flg", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "imp_tables", force: :cascade do |t|
    t.string "siten_cd"
    t.string "eigyo_order"
    t.string "eigyo_cd"
    t.string "eigyo_nm"
    t.string "manage_type_cd"
    t.string "manage_type_nm"
    t.string "trust_cd"
    t.string "building_cd"
    t.string "building_nm"
    t.string "building_type_cd"
    t.string "building_address"
    t.string "room_cd"
    t.string "room_nm"
    t.string "kanri_start_date"
    t.string "kanri_end_date"
    t.string "room_aki"
    t.string "room_type_cd"
    t.string "room_type_nm"
    t.string "room_layout_cd"
    t.string "room_layout_nm"
    t.string "owner_cd"
    t.string "owner_nm"
    t.string "owner_kana"
    t.string "owner_address"
    t.string "owner_tel"
    t.integer "biru_age"
    t.string "build_day"
    t.string "moyori_id"
    t.string "line_cd"
    t.string "line_nm"
    t.string "station_cd"
    t.string "station_nm"
    t.integer "bus_exists"
    t.integer "minuite"
    t.string "owner_postcode"
    t.string "owner_honorific_title"
    t.text "owner_memo"
    t.text "building_memo"
    t.integer "owner_type"
    t.integer "building_type"
    t.integer "execute_status", default: 0
    t.string "execute_msg"
    t.integer "biru_user_id"
    t.string "batch_code"
    t.string "list_no"
    t.string "owner_hash"
    t.string "building_hash"
    t.string "biru_rank"
    t.string "approach_01"
    t.string "approach_02"
    t.string "approach_03"
    t.string "approach_04"
    t.string "approach_05"
    t.string "proprietary_company"
    t.string "room_status_nm"
    t.string "owner_tel2"
  end

  create_table "items", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lease_contracts", force: :cascade do |t|
    t.string "code"
    t.string "start_date"
    t.string "leave_date"
    t.integer "building_id"
    t.integer "room_id"
    t.integer "lease_month"
    t.integer "rent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["building_id"], name: "index_lease_contracts_on_building_id"
    t.index ["room_id"], name: "index_lease_contracts_on_room_id"
  end

  create_table "lines", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "icon"
  end

  create_table "login_histories", force: :cascade do |t|
    t.integer "biru_user_id"
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["biru_user_id"], name: "index_login_histories_on_biru_user_id"
  end

  create_table "mail_reactions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "manage_types", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "icon"
    t.string "line_color"
  end

  create_table "market_buildings", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.real "latitude"
    t.real "longitude"
    t.boolean "gmaps"
    t.integer "shop_id"
    t.integer "build_type_id"
    t.integer "room_num"
    t.text "memo"
    t.boolean "delete_flg", default: false
    t.string "postcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "monthly_statements", force: :cascade do |t|
    t.integer "dept_id"
    t.integer "item_id"
    t.string "yyyymm"
    t.decimal "plan_value", precision: 11, scale: 2
    t.decimal "result_value", precision: 11, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dept_id", "item_id", "yyyymm"], name: "index_monthly_all"
    t.index ["dept_id"], name: "index_monthly_dept"
    t.index ["item_id", "yyyymm"], name: "index_all_2"
    t.index ["item_id"], name: "index_monthly_item"
    t.index ["yyyymm"], name: "index_monthly_yyyymm"
  end

  create_table "occur_sources", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "owner_approaches", force: :cascade do |t|
    t.integer "owner_id"
    t.date "approach_date"
    t.integer "approach_kind_id"
    t.text "content"
    t.integer "biru_user_id"
    t.boolean "delete_flg", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approach_date"], name: "index_owner_approaches_on_approach_date"
    t.index ["approach_kind_id"], name: "index_owner_approaches_on_approach_kind_id"
    t.index ["biru_user_id"], name: "index_owner_approaches_on_biru_user_id"
    t.index ["owner_id"], name: "index_owner_approaches_on_owner_id"
  end

  create_table "owner_building_logs", force: :cascade do |t|
    t.integer "owner_id"
    t.integer "building_id"
    t.integer "trust_id"
    t.text "message"
    t.integer "biru_user_id"
    t.boolean "delete_flg", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["biru_user_id"], name: "index_owner_building_logs_on_biru_user_id"
    t.index ["building_id"], name: "index_owner_building_logs_on_building_id"
    t.index ["owner_id"], name: "index_owner_building_logs_on_owner_id"
    t.index ["trust_id"], name: "index_owner_building_logs_on_trust_id"
  end

  create_table "owners", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "kana"
    t.string "address"
    t.real "latitude"
    t.real "longitude"
    t.boolean "gmaps"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "memo"
    t.integer "owner_rank_id"
    t.boolean "delete_flg", default: false
    t.string "attack_code"
    t.string "postcode"
    t.string "honorific_title"
    t.string "tel"
    t.boolean "dm_delivery", default: true
    t.integer "biru_user_id"
    t.string "hash_key"
    t.boolean "dm_ptn_1", default: false
    t.boolean "dm_ptn_2", default: false
    t.boolean "dm_ptn_3", default: false
    t.boolean "dm_ptn_4", default: false
    t.string "tel2"
    t.boolean "dm_ptn_5", default: false
    t.boolean "dm_ptn_6", default: false
    t.boolean "dm_ptn_7", default: false
    t.boolean "dm_ptn_8", default: false
    t.index ["biru_user_id"], name: "index_owners_on_biru_user_id"
    t.index ["owner_rank_id"], name: "index_owners_on_owner_rank_id"
  end

  create_table "renters_buildings", force: :cascade do |t|
    t.string "building_cd"
    t.string "building_name"
    t.string "real_building_name"
    t.string "clientcorp_building_cd"
    t.string "building_type"
    t.string "structure"
    t.string "construction"
    t.string "room_num"
    t.string "address"
    t.real "latitude"
    t.real "longitude"
    t.boolean "gmaps"
    t.string "completion_ym"
    t.boolean "delete_flg"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "access_a_line_code"
    t.string "access_a_line_name"
    t.string "access_a_station_code"
    t.string "access_a_station_name"
    t.string "access_b_line_code"
    t.string "access_b_line_name"
    t.string "access_b_station_code"
    t.string "access_b_station_name"
    t.string "access_c_line_code"
    t.string "access_c_line_name"
    t.string "access_c_station_code"
    t.string "access_c_station_name"
    t.string "access_d_line_code"
    t.string "access_d_line_name"
    t.string "access_d_station_code"
    t.string "access_d_station_name"
  end

  create_table "renters_reports", force: :cascade do |t|
    t.integer "renters_room_id"
    t.integer "renters_building_id"
    t.string "room_code"
    t.string "building_code"
    t.real "latitude"
    t.real "longitude"
    t.string "store_code"
    t.string "store_name"
    t.string "real_building_name"
    t.string "real_room_no"
    t.string "vacant_div"
    t.string "enter_ym"
    t.string "address"
    t.string "notice_a"
    t.string "notice_b"
    t.string "notice_c"
    t.string "notice_d"
    t.string "notice_e"
    t.string "notice_f"
    t.string "notice_g"
    t.string "notice_h"
    t.integer "madori_renters_madori"
    t.integer "gaikan_renters_gaikan"
    t.integer "naikan_renters_kitchen"
    t.integer "naikan_renters_toilet"
    t.integer "naikan_renters_bus"
    t.integer "naikan_renters_living"
    t.integer "naikan_renters_washroom"
    t.integer "naikan_renters_porch"
    t.integer "naikan_renters_scenery"
    t.integer "naikan_renters_equipment"
    t.integer "naikan_renters_etc"
    t.integer "gaikan_etc_renters_entrance"
    t.integer "gaikan_etc_renters_common_utility"
    t.integer "gaikan_etc_renters_raising_trees"
    t.integer "gaikan_etc_renters_parking"
    t.integer "gaikan_etc_renters_etc"
    t.integer "gaikan_etc_renters_layout"
    t.integer "syuuhen_renters_syuuhen"
    t.integer "renters_all"
    t.integer "suumo_all"
    t.integer "suumo_madori"
    t.integer "suumo_gaikan"
    t.integer "suumo_naikan"
    t.integer "suumo_gaikan_etc"
    t.integer "suumo_syuuhen"
    t.boolean "sakimono_flg"
    t.boolean "delete_flg", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "renters_room_pictures", force: :cascade do |t|
    t.integer "renters_room_id"
    t.integer "idx"
    t.string "true_url"
    t.string "large_url"
    t.string "mini_url"
    t.boolean "delete_flg", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "main_category_code"
    t.string "sub_category_code"
    t.string "sub_category_name"
    t.string "caption"
    t.string "priority"
    t.string "entry_datetime"
    t.index ["renters_room_id"], name: "index_renters_room_pictures_on_renters_room_id"
  end

  create_table "renters_rooms", force: :cascade do |t|
    t.string "room_code"
    t.string "building_code"
    t.string "clientcorp_room_cd"
    t.string "clientcorp_building_cd"
    t.string "store_code"
    t.string "store_name"
    t.string "building_name"
    t.string "room_no"
    t.string "real_building_name"
    t.string "real_room_no"
    t.string "floor"
    t.string "building_type"
    t.string "structure"
    t.string "construction"
    t.string "room_num"
    t.string "address"
    t.string "detail_address"
    t.string "vacant_div"
    t.string "enter_ym"
    t.string "new_status"
    t.string "completion_ym"
    t.string "square"
    t.string "room_layout_type"
    t.string "picture_top"
    t.string "zumen"
    t.boolean "delete_flg", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "picture_num", default: 0
    t.integer "renters_building_id"
    t.string "notice_a"
    t.string "notice_b"
    t.string "notice_c"
    t.string "notice_d"
    t.string "notice_e"
    t.string "notice_f"
    t.string "notice_g"
    t.string "notice_h"
    t.string "torihiki_mode"
    t.boolean "torihiki_mode_sakimono"
    t.index ["building_code"], name: "index_renters_rooms_on_building_code"
    t.index ["renters_building_id"], name: "index_renters_rooms_on_renters_building_id"
    t.index ["store_code"], name: "index_renters_rooms_on_store_code"
    t.index ["torihiki_mode"], name: "index_renters_rooms_on_torihiki_mode"
    t.index ["torihiki_mode_sakimono"], name: "index_renters_rooms_on_torihiki_mode_sakimono"
  end

  create_table "room_layouts", force: :cascade do |t|
    t.string "code"
    t.string "name"
  end

  create_table "room_statuses", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "room_types", force: :cascade do |t|
    t.string "code"
    t.string "name"
  end

  create_table "rooms", force: :cascade do |t|
    t.integer "building_cd"
    t.string "code"
    t.string "name"
    t.integer "room_type_id"
    t.integer "room_layout_id"
    t.integer "trust_id"
    t.integer "manage_type_id"
    t.integer "building_id"
    t.integer "rent"
    t.boolean "delete_flg", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "free_state", default: true
    t.boolean "owner_stop_state", default: false
    t.boolean "advertise_state", default: false
    t.integer "renters_room_id"
    t.integer "room_status_id"
    t.index ["building_id"], name: "index_rooms_on_building_id"
    t.index ["manage_type_id"], name: "index_rooms_on_manage_type_id"
    t.index ["renters_room_id"], name: "index_rooms_on_renters_room_id"
    t.index ["room_layout_id"], name: "index_rooms_on_room_layout_id"
    t.index ["room_status_id"], name: "index_rooms_on_room_status_id"
    t.index ["room_type_id"], name: "index_rooms_on_room_type_id"
    t.index ["trust_id"], name: "index_rooms_on_trust_id"
  end

  create_table "selectively_postcodes", force: :cascade do |t|
    t.string "postcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "selective_type"
    t.string "address"
    t.string "station_name"
    t.boolean "delete_flg", default: false
  end

  create_table "shops", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "address"
    t.real "latitude"
    t.real "longitude"
    t.boolean "gmaps"
    t.string "icon"
    t.integer "area_id"
    t.integer "group_id"
    t.string "tel"
    t.string "holiday"
    t.string "tel2"
    t.boolean "delete_flg", default: false
    t.index ["area_id"], name: "index_shops_on_area_id"
    t.index ["group_id"], name: "index_shops_on_group_id"
  end

  create_table "stations", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "line_code"
    t.integer "line_id"
    t.string "address"
    t.real "latitude"
    t.real "longitude"
    t.boolean "gmaps"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["line_id"], name: "index_stations_on_line_id"
  end

  create_table "suumo_responses", force: :cascade do |t|
    t.integer "yyyymm"
    t.integer "week_idx"
    t.integer "renters_room_id"
    t.string "renters_room_cd"
    t.integer "public_days"
    t.integer "view_list_summary"
    t.integer "view_list_daily"
    t.integer "view_detail_summary"
    t.integer "view_detail_daily"
    t.integer "inquery_visite_reserve"
    t.integer "inquery_summary"
    t.string "suumary_start_day"
    t.string "summary_end_day"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trust_attack_month_report_actions", force: :cascade do |t|
    t.integer "trust_attack_month_report_id"
    t.integer "owner_approach_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "owner_id"
    t.string "owner_code"
    t.string "owner_name"
    t.string "owner_address"
    t.real "owner_latitude"
    t.real "owner_longitude"
    t.text "content"
    t.date "approach_date"
    t.integer "approach_kind_id"
    t.string "approach_kind_code"
    t.string "approach_kind_name"
    t.boolean "delete_flg", default: false
    t.index ["owner_approach_id"], name: ":trust_attack_month_report_owner_approach_pk"
    t.index ["trust_attack_month_report_id"], name: ":trust_attack_month_report_id_pk"
  end

  create_table "trust_attack_month_report_ranks", force: :cascade do |t|
    t.integer "trust_attack_month_report_id"
    t.integer "attack_state_last_month_id"
    t.integer "attack_state_this_month_id"
    t.integer "change_status"
    t.string "change_month"
    t.integer "trust_id"
    t.integer "owner_id"
    t.integer "building_id"
    t.string "building_name"
    t.real "building_latitude"
    t.real "building_longitude"
    t.boolean "delete_flg", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "approach_cnt"
    t.integer "room_num"
    t.index ["building_id"], name: "index_trust_attack_month_report_ranks_on_building_id"
    t.index ["trust_attack_month_report_id"], name: "trsut_attack_report_rank_report_id"
  end

  create_table "trust_attack_month_report_results", force: :cascade do |t|
    t.integer "trust_attack_month_report_id"
    t.string "trust_apply_code"
    t.string "shop_name"
    t.string "apply_type_name"
    t.string "building_name"
    t.integer "yourself_num"
    t.integer "oneself_num"
    t.float "point", default: 0.0
    t.boolean "delete_flg", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "comment"
    t.datetime "comment_updated_at"
    t.integer "comment_updated_user"
  end

  create_table "trust_attack_month_report_update_histories", force: :cascade do |t|
    t.string "month"
    t.datetime "start_datetime"
    t.datetime "update_datetime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trust_attack_month_reports", force: :cascade do |t|
    t.string "month"
    t.integer "biru_user_id"
    t.string "biru_usr_name"
    t.string "trust_report_url"
    t.string "attack_list_url"
    t.integer "visit_plan"
    t.integer "dm_plan"
    t.integer "tel_plan"
    t.integer "trust_num"
    t.integer "rank_s"
    t.integer "rank_a"
    t.integer "rank_b"
    t.integer "rank_c"
    t.integer "rank_d"
    t.integer "rank_c_over"
    t.integer "rank_d_over"
    t.integer "rank_all"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "trust_plan"
    t.integer "trust_num_jisya"
    t.integer "rank_w"
    t.integer "rank_x"
    t.integer "rank_y"
    t.integer "rank_z"
    t.integer "visit_num_all"
    t.integer "visit_num_meet"
    t.integer "dm_num_send"
    t.integer "dm_num_recv"
    t.integer "tel_num_call"
    t.integer "tel_num_talk"
    t.integer "suggestion_plan"
    t.integer "suggestion_num"
    t.integer "fluctuate_s"
    t.integer "fluctuate_a"
    t.integer "fluctuate_b"
    t.integer "fluctuate_c"
    t.integer "fluctuate_d"
    t.integer "fluctuate_w"
    t.integer "fluctuate_x"
    t.integer "fluctuate_y"
    t.integer "fluctuate_z"
    t.string "area_name"
    t.integer "dm_to_tel_plan"
    t.integer "dm_to_tel_result"
    t.real "dm_to_tel_average"
    t.integer "visit_meet_plan"
    t.real "visit_meet_par"
    t.integer "approach_cnt_s", default: 0
    t.integer "approach_cnt_a", default: 0
    t.integer "approach_cnt_b", default: 0
    t.integer "approach_cnt_c", default: 0
    t.integer "approach_cnt_z", default: 0
    t.integer "dm_to_tel_result_both"
    t.text "comment_user_could"
    t.text "comment_user_not_could"
    t.text "comment_user_plan"
    t.integer "comment_user_updated_user_id"
    t.datetime "comment_user_updated_at"
    t.text "comment_boss_could"
    t.text "comment_boss_not_could"
    t.text "comment_boss_plan"
    t.integer "comment_boss_updated_user_id"
    t.datetime "comment_boss_updated_at"
    t.integer "apply_yourself_num"
    t.integer "apply_oneself_num"
    t.float "apply_point"
  end

  create_table "trust_attack_permissions", force: :cascade do |t|
    t.integer "holder_user_id"
    t.integer "permit_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trust_attack_state_histories", force: :cascade do |t|
    t.integer "trust_id"
    t.integer "month"
    t.integer "attack_state_from_id"
    t.integer "attack_state_to_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "room_num"
    t.boolean "trust_oneself", default: false
    t.integer "manage_type_id"
    t.index ["attack_state_from_id"], name: "index_trust_attack_state_histories_on_attack_state_from_id"
    t.index ["attack_state_to_id"], name: "index_trust_attack_state_histories_on_attack_state_to_id"
    t.index ["manage_type_id"], name: "index_trust_attack_state_histories_on_manage_type_id"
    t.index ["month"], name: "index_trust_attack_state_histories_on_month"
    t.index ["trust_id"], name: "index_trust_attack_state_histories_on_trust_id"
  end

  create_table "trust_maintenances", force: :cascade do |t|
    t.integer "trust_id"
    t.integer "idx"
    t.string "code"
    t.string "name"
    t.integer "price"
    t.boolean "delete_flg", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delete_flg"], name: "index_trust_maintenances_on_delete_flg"
    t.index ["trust_id"], name: "index_trust_maintenances_on_trust_id"
  end

  create_table "trust_rewindings", force: :cascade do |t|
    t.string "trust_code"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trusts", force: :cascade do |t|
    t.integer "owner_id"
    t.integer "building_id"
    t.integer "manage_type_id"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "delete_flg", default: false
    t.integer "biru_user_id"
    t.integer "attack_state_id"
    t.index ["biru_user_id"], name: "index_trusts_on_biru_user_id"
    t.index ["building_id"], name: "index_trusts_on_building_id"
    t.index ["manage_type_id"], name: "index_trusts_on_manage_type_id"
    t.index ["owner_id"], name: "index_trusts_on_owner_id"
  end

  create_table "vacant_rooms", force: :cascade do |t|
    t.string "yyyymm"
    t.integer "room_id"
    t.integer "shop_id"
    t.integer "building_id"
    t.integer "manage_type_id"
    t.integer "room_layout_id"
    t.string "vacant_start_day"
    t.integer "vacant_cnt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["building_id"], name: "index_vacant_rooms_on_building_id"
    t.index ["manage_type_id"], name: "index_vacant_rooms_on_manage_type_id"
    t.index ["room_id"], name: "index_vacant_rooms_on_room_id"
    t.index ["room_layout_id"], name: "index_vacant_rooms_on_room_layout_id"
    t.index ["shop_id"], name: "index_vacant_rooms_on_shop_id"
  end

  create_table "work_renters_room_pictures", force: :cascade do |t|
    t.string "batch_cd"
    t.integer "batch_cd_idx"
    t.string "room_cd"
    t.integer "batch_picture_idx"
    t.string "true_url"
    t.string "large_url"
    t.string "mini_url"
    t.string "main_category_code"
    t.string "sub_category_code"
    t.string "sub_category_name"
    t.string "caption"
    t.string "priority"
    t.string "entry_datetime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["batch_cd"], name: "index_work_renters_room_pictures_on_batch_cd"
    t.index ["batch_cd_idx"], name: "index_work_renters_room_pictures_on_batch_cd_idx"
    t.index ["batch_picture_idx"], name: "index_work_renters_room_pictures_on_batch_picture_idx"
  end

  create_table "work_renters_rooms", force: :cascade do |t|
    t.string "batch_cd"
    t.integer "batch_cd_idx"
    t.string "room_cd"
    t.string "building_cd"
    t.string "clientcorp_room_cd"
    t.string "clientcorp_building_cd"
    t.string "store_code"
    t.string "store_name"
    t.string "building_name"
    t.string "gaikugoutou"
    t.string "room_no"
    t.string "real_building_name"
    t.string "real_gaikugoutou"
    t.string "real_room_no"
    t.string "floor"
    t.string "building_type"
    t.string "structure"
    t.string "construction"
    t.string "room_num"
    t.string "address"
    t.string "detail_address"
    t.string "pref_code"
    t.string "pref_name"
    t.string "city_code"
    t.string "city_name"
    t.string "choume_code"
    t.string "choume_name"
    t.string "latitude"
    t.string "longitude"
    t.string "vacant_div"
    t.string "enter_ym"
    t.string "new_status"
    t.string "completion_ym"
    t.string "square"
    t.string "room_layout_type"
    t.integer "work_renters_room_layout_id"
    t.integer "work_renters_access_id"
    t.string "cond"
    t.string "contract_div"
    t.string "contract_comment"
    t.string "rent_amount"
    t.string "managing_fee"
    t.string "reikin"
    t.string "shikihiki"
    t.string "shikikin"
    t.string "shoukyakukin"
    t.string "hoshoukin"
    t.string "renewal_fee"
    t.string "insurance"
    t.string "agent_fee"
    t.string "other_fee"
    t.string "airconditioner"
    t.string "washer_space"
    t.string "burner"
    t.string "equipment"
    t.string "carpark_status"
    t.string "carpark_fee"
    t.string "carpark_reikin"
    t.string "carpark_shikikin"
    t.string "carpark_distance_to_nearby"
    t.string "carpark_car_num"
    t.string "carpark_indoor"
    t.string "carpark_shape"
    t.string "carpark_underground"
    t.string "carpark_roof"
    t.string "carpark_shutter"
    t.string "notice"
    t.string "building_main_catch"
    t.string "room_main_catch"
    t.string "recruit_catch"
    t.string "room_updated_at"
    t.integer "work_renters_picture_id"
    t.string "zumen_url"
    t.string "location"
    t.string "net_use_freecomment"
    t.string "athome_pro_comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "notice_a"
    t.string "notice_b"
    t.string "notice_c"
    t.string "notice_d"
    t.string "notice_e"
    t.string "notice_f"
    t.string "notice_g"
    t.string "notice_h"
    t.string "torihiki_mode"
    t.string "access_a_line_code"
    t.string "access_a_line_name"
    t.string "access_a_station_code"
    t.string "access_a_station_name"
    t.string "access_b_line_code"
    t.string "access_b_line_name"
    t.string "access_b_station_code"
    t.string "access_b_station_name"
    t.string "access_c_line_code"
    t.string "access_c_line_name"
    t.string "access_c_station_code"
    t.string "access_c_station_name"
    t.string "access_d_line_code"
    t.string "access_d_line_name"
    t.string "access_d_station_code"
    t.string "access_d_station_name"
    t.index ["batch_cd"], name: "index_work_renters_rooms_on_batch_cd"
    t.index ["building_cd"], name: "index_work_renters_rooms_on_building_cd"
  end

  create_table "廃棄_backup_buildings", force: :cascade do |t|
    t.string "code"
    t.string "attack_code"
    t.string "name"
    t.string "address"
    t.integer "shop_id"
    t.integer "build_type_id"
    t.integer "room_num"
    t.real "latitude"
    t.real "longitude"
    t.boolean "gmaps"
    t.string "tmp_manage_type_icon"
    t.string "tmp_build_type_icon"
    t.boolean "delete_flg", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "廃棄_backup_owners", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "address"
    t.real "latitude"
    t.real "longitude"
    t.boolean "gmaps"
    t.boolean "delete_flg", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
