# -*- encoding:utf-8 -*-

require "csv"

# 建物管理を表示するコントローラ
class BiruServiceController < ApplicationController
  before_action :room_all_action

  # 物件種別のiconを変更する時のコントローラ
  def change_biru_icon
    p "パラメータ " + params[:disp_type].to_s
    @biru_icon = params[:disp_type]
  end

  def index
    @data_update = DataUpdateTime.find_by_code("110")

    # 管理物件、巡回清掃、定期メンテ、在宅清掃が入っている一覧表を営業所別に作成
    data_list = []
    arr_tobu = []
    arr_saitama = []
    arr_chiba = []
    arr_unknown = []

    ##############################
    # jqgridに渡す営業所別の枠を作成
    ##############################
    group_name = ""
    Shop.all.each do |shop|
      case shop.group_id
      when 1
        group_name = "01東武"
        arr_tobu.push(shop.code)
      when 2
        group_name = "02さいたま"
        arr_saitama.push(shop.code)
      when 3
        group_name = "03千葉"
        arr_chiba.push(shop.code)
      else
        group_name = "99その他"
        arr_unknown.push(shop.code)
      end

      data_list.push({
        shop_code: shop.code, shop_name: shop.name, group_name: group_name, url: "map" + @room_all_params + "?stcd=" + shop.code, building_cnt: 0, room_cnt: 0, biru_type_mn_cnt: 0, biru_type_bm_cnt: 0, biru_type_ap_cnt: 0, biru_type_kdt_cnt: 0, biru_type_etc_cnt: 0, trust_mente_junkai_seisou_cnt: 0, trust_mente_syoubou_setubi_cnt: 0, trust_mente_kyusui_setubi_cnt: 0, trust_mente_tyosui_seisou_cnt: 0, trust_mente_elevator_hosyu_cnt: 0, trust_mente_bouhan_camera_cnt: 0
      })
    end

    data_list.push({ shop_code: "100", shop_name: "東武支店", group_name: "00支店", url: "map" + @room_all_params + "?stcd=" + arr_tobu.join(","), building_cnt: 0, room_cnt: 0, biru_type_mn_cnt: 0, biru_type_bm_cnt: 0, biru_type_ap_cnt: 0, biru_type_kdt_cnt: 0, biru_type_etc_cnt: 0, trust_mente_junkai_seisou_cnt: 0, trust_mente_syoubou_setubi_cnt: 0, trust_mente_kyusui_setubi_cnt: 0, trust_mente_tyosui_seisou_cnt: 0, trust_mente_elevator_hosyu_cnt: 0, trust_mente_bouhan_camera_cnt: 0 })
    data_list.push({ shop_code: "200", shop_name: "さいたま支店", group_name: "00支店", url: "map" + @room_all_params + "?stcd=" + arr_saitama.join(","), building_cnt: 0, room_cnt: 0, biru_type_mn_cnt: 0, biru_type_bm_cnt: 0, biru_type_ap_cnt: 0, biru_type_kdt_cnt: 0, biru_type_etc_cnt: 0, trust_mente_junkai_seisou_cnt: 0, trust_mente_syoubou_setubi_cnt: 0, trust_mente_kyusui_setubi_cnt: 0, trust_mente_tyosui_seisou_cnt: 0, trust_mente_elevator_hosyu_cnt: 0, trust_mente_bouhan_camera_cnt: 0 })
    data_list.push({ shop_code: "300", shop_name: "千葉支店", group_name: "00支店", url: "map" + @room_all_params + "?stcd=" + arr_chiba.join(","), building_cnt: 0, room_cnt: 0, biru_type_mn_cnt: 0, biru_type_bm_cnt: 0, biru_type_ap_cnt: 0, biru_type_kdt_cnt: 0, biru_type_etc_cnt: 0, trust_mente_junkai_seisou_cnt: 0, trust_mente_syoubou_setubi_cnt: 0, trust_mente_kyusui_setubi_cnt: 0, trust_mente_tyosui_seisou_cnt: 0, trust_mente_elevator_hosyu_cnt: 0, trust_mente_bouhan_camera_cnt: 0 })
    data_list.push({ shop_code: "900", shop_name: "ビル全体", group_name: "99その他", url: "map" + @room_all_params + "?all=99", building_cnt: 0, room_cnt: 0, biru_type_mn_cnt: 0, biru_type_bm_cnt: 0, biru_type_ap_cnt: 0, biru_type_kdt_cnt: 0, biru_type_etc_cnt: 0, trust_mente_junkai_seisou_cnt: 0, trust_mente_syoubou_setubi_cnt: 0, trust_mente_kyusui_setubi_cnt: 0, trust_mente_tyosui_seisou_cnt: 0, trust_mente_elevator_hosyu_cnt: 0, trust_mente_bouhan_camera_cnt: 0 })

    ##############################
    # 営業所データをハッシュに格納
    ##############################
    grid_data = {}
    ActiveRecord::Base.connection.select_all(get_shop_list_sql(@room_all_flg)).each do |rec|
      unless grid_data[rec["shop_code"]]
        grid_data[rec["shop_code"]] = {
           shop_code: rec["shop_code"],
           building_cnt: rec["building_cnt"],
           room_cnt: rec["shop_room_cnt"],

           biru_type_mn_cnt: rec["biru_type_mn_cnt"],
           biru_type_bm_cnt: rec["biru_type_bm_cnt"],
           biru_type_ap_cnt: rec["biru_type_ap_cnt"],
           biru_type_kdt_cnt: rec["biru_type_kdt_cnt"],
           biru_type_etc_cnt: rec["biru_type_etc_cnt"],

           trust_mente_junkai_seisou_cnt: rec["trust_mente_junkai_seisou_cnt"],
           trust_mente_syoubou_setubi_cnt: rec["trust_mente_syoubou_setubi_cnt"],
           trust_mente_kyusui_setubi_cnt: rec["trust_mente_kyusui_setubi_cnt"],
           trust_mente_tyosui_seisou_cnt: rec["trust_mente_tyosui_seisou_cnt"],
           trust_mente_elevator_hosyu_cnt: rec["trust_mente_elevator_hosyu_cnt"],
           trust_mente_bouhan_camera_cnt: rec["trust_mente_bouhan_camera_cnt"]
         }
      end
    end

    ##############################
    # 営業所の枠に取得した値を格納
    ##############################
    toubu_hash = {
      building_cnt: 0,
      room_cnt: 0,
      biru_type_mn_cnt: 0,
      biru_type_bm_cnt: 0,
      biru_type_ap_cnt: 0,
      biru_type_kdt_cnt: 0,
      biru_type_etc_cnt: 0,

      trust_mente_junkai_seisou_cnt: 0,
      trust_mente_syoubou_setubi_cnt: 0,
      trust_mente_kyusui_setubi_cnt: 0,
      trust_mente_tyosui_seisou_cnt: 0,
      trust_mente_elevator_hosyu_cnt: 0,
      trust_mente_bouhan_camera_cnt: 0

    }

    saitama_hash = {
      building_cnt: 0,
      room_cnt: 0,
      biru_type_mn_cnt: 0,
      biru_type_bm_cnt: 0,
      biru_type_ap_cnt: 0,
      biru_type_kdt_cnt: 0,
      biru_type_etc_cnt: 0,

      trust_mente_junkai_seisou_cnt: 0,
      trust_mente_syoubou_setubi_cnt: 0,
      trust_mente_kyusui_setubi_cnt: 0,
      trust_mente_tyosui_seisou_cnt: 0,
      trust_mente_elevator_hosyu_cnt: 0,
      trust_mente_bouhan_camera_cnt: 0

    }

    chiba_hash = {
      building_cnt: 0,
      room_cnt: 0,
      biru_type_mn_cnt: 0,
      biru_type_bm_cnt: 0,
      biru_type_ap_cnt: 0,
      biru_type_kdt_cnt: 0,
      biru_type_etc_cnt: 0,

      trust_mente_junkai_seisou_cnt: 0,
      trust_mente_syoubou_setubi_cnt: 0,
      trust_mente_kyusui_setubi_cnt: 0,
      trust_mente_tyosui_seisou_cnt: 0,
      trust_mente_elevator_hosyu_cnt: 0,
      trust_mente_bouhan_camera_cnt: 0

    }

    etc_hash = {
      building_cnt: 0,
      room_cnt: 0,
      biru_type_mn_cnt: 0,
      biru_type_bm_cnt: 0,
      biru_type_ap_cnt: 0,
      biru_type_kdt_cnt: 0,
      biru_type_etc_cnt: 0,

      trust_mente_junkai_seisou_cnt: 0,
      trust_mente_syoubou_setubi_cnt: 0,
      trust_mente_kyusui_setubi_cnt: 0,
      trust_mente_tyosui_seisou_cnt: 0,
      trust_mente_elevator_hosyu_cnt: 0,
      trust_mente_bouhan_camera_cnt: 0

    }


    data_list.each do |data_hash|
      if data_hash[:group_name] == "00支店"
        # 支店データを設定
        if data_hash[:shop_name] == "東武支店"
          data_hash.keys.each do |key|
            if key != :shop_code and key != :shop_name and key != :group_name and key != :url
              data_hash[key] = toubu_hash[key]
            end
          end

          # ここでやっていること↑
          # data_hash[:building_cnt] = toubu_building_cnt
          # data_hash[:room_cnt] = toubu_room_cnt

        elsif data_hash[:shop_name] == "さいたま支店"
          data_hash.keys.each do |key|
            if key != :shop_code and key != :shop_name and key != :group_name and key != :url
              data_hash[key] = saitama_hash[key]
            end
          end

        elsif data_hash[:shop_name] == "千葉支店"
          data_hash.keys.each do |key|
            if key != :shop_code and key != :shop_name and key != :group_name and key != :url
              data_hash[key] = chiba_hash[key]
            end
          end
        end

      elsif data_hash[:group_name] == "99その他" && data_hash[:shop_name] == "ビル全体"

          # data_hash[:building_cnt] = toubu_building_cnt + saitama_building_cnt + chiba_building_cnt + etc_building_cnt
          # data_hash[:room_cnt] = toubu_room_cnt + saitama_room_cnt + chiba_room_cnt + etc_room_cnt

          data_hash.keys.each do |key|
            if key != :shop_code and key != :shop_name and key != :group_name and key != :url
              data_hash[key] = toubu_hash[key].to_i + saitama_hash[key].to_i + chiba_hash[key].to_i
            end
          end

      else

        # 営業所のデータを取得
        grid_rec = grid_data[data_hash[:shop_code]]
        if grid_rec

          data_hash.keys.each do |key|
            if key != :shop_code and key != :shop_name and key != :group_name and key != :url
              data_hash[key] = grid_rec[key]
            end
          end

          # ここでやっていること↑
          # data_hash[:building_cnt] = grid_rec[:building_cnt]
          # data_hash[:room_cnt] = grid_rec[:room_cnt]
          # data_hash[:biru_type_mn_cnt] = grid_rec[:biru_type_mn_cnt]
          # data_hash[:biru_type_bm_cnt] = grid_rec[:biru_type_bm_cnt]
          # data_hash[:biru_type_ap_cnt] = grid_rec[:biru_type_ap_cnt]
          # data_hash[:biru_type_kdt_cnt] = grid_rec[:biru_type_kdt_cnt]
          # data_hash[:biru_type_etc_cnt] = grid_rec[:biru_type_etc_cnt]


          if data_hash[:group_name] == "01東武"

            toubu_hash.keys.each do |key|
              if key != :shop_code and key != :shop_name and key != :group_name and key != :url
                toubu_hash[key] = toubu_hash[key] + grid_rec[key]
              end
            end


          elsif data_hash[:group_name] == "02さいたま"
            saitama_hash.keys.each do |key|
              if key != :shop_code and key != :shop_name and key != :group_name and key != :url
                saitama_hash[key] = saitama_hash[key] + grid_rec[key]
              end
            end

          elsif data_hash[:group_name] == "03千葉"
            chiba_hash.keys.each do |key|
              if key != :shop_code and key != :shop_name and key != :group_name and key != :url
                chiba_hash[key] = chiba_hash[key] + grid_rec[key]
              end
            end

          else

            etc_hash.keys.each do |key|
              if key != :shop_code and key != :shop_name and key != :group_name and key != :url
                etc_hash[key] = etc_hash[key] + grid_rec[key]
              end
            end

          end

        end

      end
    end

    gon.data_list = data_list
  end

  def map
    ##########################
    # 取得する営業所の絞り込み
    ##########################
    @shop_where = ""
    if params[:stcd]
      params[:stcd].split(",").each do |store_code|
        # 数字になり得るのなら引数として採用
        if store_code.strip =~ /\A-?\d+(.\d+)?\Z/

          unless @shop_where.length == 0
            @shop_where = @shop_where + ","
          end

          @shop_where = @shop_where + store_code

        end
      end
    end


    ##############################
    # 物件・営業所・貸主と紐付きの取得
    ##############################
    buildings = []
    shops = []
    owners = []
    trusts = []
    owner_to_buildings = {}
    building_to_owners = {}

    # 登録済みチェック用
    check_building = {} # 管理方式が異なり同じ建物が2度くることが無いとはいえないので念のため一意になるようチェック
    check_owner = {}
    check_shop = {}
    check_trust = {}

    grid_data = []

    ActiveRecord::Base.connection.select_all(get_biru_list_sql(@shop_where, false, @room_all_flg)).each do |rec|
      ####################
      # 地図で使う物件情報
      ####################
      biru = {
        id: rec["building_id"],
        name: rec["building_name"],
        latitude: rec["building_latitude"],
        longitude: rec["building_longitude"],
        build_type_icon: rec["buid_type_icon"],
        room_cnt: rec["room_cnt"],
        free_cnt: rec["free_cnt"],
        biru_age: rec["biru_age"],
        manage_type_icon: rec["manage_type_icon"],
        shop_code: rec["shop_code"],

        trust_mente_junkai_seisou: rec["trust_mente_junkai_seisou"],
        trust_mente_syoubou_setubi: rec["trust_mente_syoubou_setubi"],
        trust_mente_kyusui_setubi: rec["trust_mente_kyusui_setubi"],
        trust_mente_tyosui_seisou: rec["trust_mente_tyosui_seisou"],
        trust_mente_elevator_hosyu: rec["trust_mente_elevator_hosyu"],
        trust_mente_bouhan_camera: rec["trust_mente_bouhan_camera"]

      }


      unless check_building[biru[:id]]
        buildings.push(biru)
        check_building[biru[:id]] = true
      end

      # 営業所の登録
      unless check_shop[rec["shop_id"]]
        shop = { id: rec["shop_id"], name: rec["shop_name"], latitude: rec["shop_latitude"], longitude: rec["shop_longitude"], icon: rec["shop_icon"] }
        shops.push(shop)
        check_shop[shop[:id]] = true
      end

      # 貸主の登録
      owner = { id: rec["owner_id"], name: rec["owner_name"], latitude: rec["owner_latitude"], longitude: rec["owner_longitude"] }
      unless check_owner[owner[:id]]
        owners.push(owner)
        check_owner[owner[:id]] = true
      end

      # 貸主に対する紐付きの作成
      owner_to_buildings[owner[:id]] = [] unless owner_to_buildings[owner[:id]]
      owner_to_buildings[owner[:id]] << biru

      # 建物に紐づく貸主一覧を作成する。※本来建物に対するオーナーは１人だが、念のため複数オーナーも対応する。
      building_to_owners[biru[:id]] = [] unless building_to_owners[biru[:id]]
      building_to_owners[biru[:id]] << owner

      # 委託の登録
      trust = { id: rec["trust_id"], owner_id: owner[:id], building_id: biru[:id] }
      unless check_trust[trust[:id]]
        trusts.push(trust)
        check_trust[trust[:id]] = true
      end

      ########################
      # 一覧表で使う情報
      ########################
      row_data = {}
      row_data[:trsut_id] = rec["trust_id"]
      row_data[:building_id] = rec["building_id"]
      row_data[:shop_name] = rec["shop_name"]
      row_data[:building_code] = rec["building_code"]
      row_data[:building_name] = rec["building_name"]
      row_data[:building_address] = rec["building_address"]
      row_data[:room_cnt] = rec["room_cnt"]
      row_data[:owner_code] = rec["owner_code"]
      row_data[:owner_address] = rec["owner_address"]
      row_data[:owner_name] = rec["owner_name"]

      row_data[:build_type_name] = rec["build_type_name"]
      row_data[:manage_type_name] = rec["manage_type_name"]

      row_data[:free_par] = "%.1f"%(rec["free_cnt"].to_f / rec["room_cnt"].to_f * 100).to_f unless rec["room_cnt"] == 0

      row_data[:free_cnt] = rec["free_cnt"]
      row_data[:biru_age] = rec["biru_age"]

      row_data[:trust_mente_junkai_seisou] = rec["trust_mente_junkai_seisou"]
      row_data[:trust_mente_syoubou_setubi] = rec["trust_mente_syoubou_setubi"]
      row_data[:trust_mente_kyusui_setubi] = rec["trust_mente_kyusui_setubi"]
      row_data[:trust_mente_tyosui_seisou] = rec["trust_mente_tyosui_seisou"]
      row_data[:trust_mente_elevator_hosyu] = rec["trust_mente_elevator_hosyu"]
      row_data[:trust_mente_bouhan_camera] = rec["trust_mente_bouhan_camera"]

      grid_data.push(row_data)
    end

    gon.buildings = buildings
    gon.owners = owners
    gon.trusts = trusts
    gon.shops = shops
    gon.owner_to_buildings = owner_to_buildings
    gon.building_to_owners = building_to_owners

    gon.grid_data = grid_data

    # 一覧のコンボボックス
    @combo_shop = jqgrid_combo_shop
    @combo_build_type = jqgrid_combo_build_type
    @combo_manage_type = jqgrid_combo_manage_type
  end


  # ファイル出力（CSV出力）
  def csv_out
    str = ""

    # params[:data].keys.each do |key|
    #   str = str + params[:data][key].values.join(',')
    #   str = str + "\n"
    # end

    # csvデータ作成
    data = ActiveRecord::Base.connection.select_all(get_biru_list_sql(params[:shop_list], true, @room_all_flg))

    keys = [ "shop_name", "building_code", "building_name", "manage_type_name", "build_type_name", "room_name", "room_status" ]

    data.each do |row|
      keys.each do |key|
        str = str + row[key].to_s + ","
      end
      str = str + "\n"
    end

    send_data str, filename: "output_room.csv"
  end



private
  # 自社管理（B以上）の物件を戸数単位で営業所別に表示する
  # アパート・マンションのみ
  # １棟管理のみ（＝戸数が4戸以上）
  # 150平米以上

  # room_flg : 部屋単位の出力をする
  # room_all : trueの時、近隣のみ出力
  def get_biru_list_sql(shop_list, room_flg = false, room_all = false)
    strSql = ""
    strSql = strSql + "select "
    strSql = strSql + " a.id as building_id "
    strSql = strSql + ",a.code as building_code "
    strSql = strSql + ",a.name as building_name "
    strSql = strSql + ",a.address as building_address "
    strSql = strSql + ",a.latitude as building_latitude "
    strSql = strSql + ",a.longitude as building_longitude "

    strSql = strSql + ",c.id as shop_id "
    strSql = strSql + ",c.code as shop_code "
    strSql = strSql + ",c.name as shop_name "
    strSql = strSql + ",c.address as shop_address "
    strSql = strSql + ",c.latitude as shop_latitude "
    strSql = strSql + ",c.longitude as shop_longitude "
    strSql = strSql + ",c.icon as shop_icon "

    strSql = strSql + ",f.id as owner_id "
    strSql = strSql + ",f.code as owner_code "
    strSql = strSql + ",f.name as owner_name "
    strSql = strSql + ",f.address as owner_address "
    strSql = strSql + ",f.latitude as owner_latitude "
    strSql = strSql + ",f.longitude as owner_longitude "

    strSql = strSql + ",d.id as trust_id "
    strSql = strSql + ",e.name as manage_type_name "
    strSql = strSql + ",e.icon as manage_type_icon "

    strSql = strSql + ",g.code as build_type_code "
    strSql = strSql + ",g.name as build_type_name "
    strSql = strSql + ",g.icon as buid_type_icon "

    # strSql = strSql + ",count(b.id) as room_cnt "
    # strSql = strSql + ",SUM(CASE free_state when 't' then 1 else 0 end) as free_cnt "
    strSql = strSql + ",a.kanri_room_num as room_cnt "
    strSql = strSql + ",a.free_num as free_cnt "
    strSql = strSql + ",a.biru_age as biru_age "

    strSql = strSql + ",MAX(case h.code when '3' then 1 else 0 end ) trust_mente_junkai_seisou "
    strSql = strSql + ",MAX(case h.code when '20' then 1 else 0 end ) trust_mente_syoubou_setubi "
    strSql = strSql + ",MAX(case h.code when '15' then 1 else 0 end ) trust_mente_kyusui_setubi "
    strSql = strSql + ",MAX(case h.code when '25' then 1 else 0 end ) trust_mente_tyosui_seisou "
    strSql = strSql + ",MAX(case h.code when '45' then 1 else 0 end ) trust_mente_elevator_hosyu "
    strSql = strSql + ",MAX(case h.code when '48' then 1 else 0 end ) trust_mente_bouhan_camera "

    strSql = strSql + ",SUM(case j.code when '10' then 1 else 0 end ) room_status_unrecognized "
    strSql = strSql + ",SUM(case j.code when '20' then 1 else 0 end ) room_status_owner_stop "
    strSql = strSql + ",SUM(case j.code when '30' then 1 else 0 end ) room_status_space "
    strSql = strSql + ",SUM(case j.code when '40' then 1 else 0 end ) room_status_occupancy "
    strSql = strSql + ",SUM(case j.code when '50' then 1 else 0 end ) room_status_etc "

    if room_flg then
      strSql = strSql + ",b.name as room_name "
      strSql = strSql + ",j.name as room_status "
    end

    strSql = strSql + "from buildings a "
    strSql = strSql + "inner join rooms b on a.id = b.building_id "
    strSql = strSql + "inner join shops c on c.id = a.shop_id "
    strSql = strSql + "inner join trusts d on a.id = d.building_id "
    strSql = strSql + "inner join manage_types e on e.id = b.manage_type_id  "
    strSql = strSql + "inner join owners f on d.owner_id = f.id "
    strSql = strSql + "inner join build_types g on a.build_type_id = g.id "
    strSql = strSql + "inner join room_statuses j on b.room_status_id = j.id "
    strSql = strSql + "left outer join (select * from trust_maintenances where delete_flg = 0 ) h on h.trust_id = d.id "
    strSql = strSql + "where 1 = 1  "
    strSql = strSql + "and c.code in ( " + shop_list + ") " if shop_list.length > 0

    strSql = strSql + "and a.room_all_flg = 1 and e.code = '3'  " if room_all # SQLServerは1  B管理のみ

    strSql = strSql + "and a.delete_flg = 0 "
    strSql = strSql + "and b.delete_flg = 0 "
    strSql = strSql + "and d.delete_flg = 0 "
    strSql = strSql + "and e.code in (3,4,5,6,9, 7,8,10) "
    strSql = strSql + "group by a.id "
    strSql = strSql + ",a.code"
    strSql = strSql + ",a.name"
    strSql = strSql + ",a.address"
    strSql = strSql + ",a.latitude"
    strSql = strSql + ",a.longitude"
    strSql = strSql + ",c.id"
    strSql = strSql + ",c.code"
    strSql = strSql + ",c.name"
    strSql = strSql + ",c.address"
    strSql = strSql + ",c.latitude"
    strSql = strSql + ",c.longitude"
    strSql = strSql + ",c.icon"
    strSql = strSql + ",d.id "
    strSql = strSql + ",e.name "
    strSql = strSql + ",e.icon "
    strSql = strSql + ",f.id "
    strSql = strSql + ",f.code "
    strSql = strSql + ",f.name "
    strSql = strSql + ",f.address "
    strSql = strSql + ",f.latitude "
    strSql = strSql + ",f.longitude "
    strSql = strSql + " ,g.name"
    strSql = strSql + " ,g.code"
    strSql = strSql + " ,g.icon"
    strSql = strSql + " ,a.kanri_room_num"
    strSql = strSql + " ,a.free_num"
    strSql = strSql + " ,a.biru_age"

    if room_flg then
      strSql = strSql + ",b.name "
      strSql = strSql + ",j.name "
    end

    strSql = strSql + " "

    strSql
  end

  def get_shop_list_sql(room_all_flg = false)
    strSql = ""
    strSql = strSql + "SELECT "
    strSql = strSql + "shop_id "
    strSql = strSql + ",shop_name "
    strSql = strSql + ",shop_code "
    strSql = strSql + ",count(*) as building_cnt "
    strSql = strSql + ",SUM(case when build_type_code = '01010' then 1 else 0 end ) as biru_type_mn_cnt "
    strSql = strSql + ",SUM(case when build_type_code = '01015' then 1 else 0 end ) as biru_type_bm_cnt "
    strSql = strSql + ",SUM(case when build_type_code = '01020' then 1 else 0 end ) as biru_type_ap_cnt "
    strSql = strSql + ",SUM(case when build_type_code = '01025' then 1 else 0 end ) as biru_type_kdt_cnt "
    strSql = strSql + ",SUM(case when build_type_code in ('01010', '01015', '01020', '01025' ) then 0 else 1 end ) as biru_type_etc_cnt "
    strSql = strSql + ",SUM( trust_mente_junkai_seisou ) as trust_mente_junkai_seisou_cnt "
    strSql = strSql + ",SUM( trust_mente_syoubou_setubi ) as trust_mente_syoubou_setubi_cnt "
    strSql = strSql + ",SUM( trust_mente_kyusui_setubi ) as trust_mente_kyusui_setubi_cnt "
    strSql = strSql + ",SUM( trust_mente_tyosui_seisou ) as trust_mente_tyosui_seisou_cnt "
    strSql = strSql + ",SUM( trust_mente_elevator_hosyu ) as trust_mente_elevator_hosyu_cnt "
    strSql = strSql + ",SUM( trust_mente_bouhan_camera ) as trust_mente_bouhan_camera_cnt "
    strSql = strSql + ",sum(room_cnt) as shop_room_cnt "
    strSql = strSql + ",SUM(room_status_unrecognized) as room_status_unrecognized_sum "
    strSql = strSql + ",SUM(room_status_owner_stop) as room_status_owner_stop_sum "
    strSql = strSql + ",SUM(room_status_space) as room_status_space_sum "
    strSql = strSql + ",SUM(room_status_occupancy) as room_status_occupancy_sum "
    strSql = strSql + ",SUM(room_status_etc) as room_status_etc_sum "

    strSql = strSql + "FROM (" + get_biru_list_sql("", false, room_all_flg) + ") X "
    strSql = strSql + "GROUP BY shop_id, shop_name, shop_code "

    strSql
  end

  # 近隣のチェック
  def room_all_action
    # １棟管理物件か確認する
    @room_all_flg = false
    @room_all_params = ""
    if params[:room_all] == "room_all"
      @room_all_flg = true
      @room_all_params = "/room_all"
    end
  end
end
