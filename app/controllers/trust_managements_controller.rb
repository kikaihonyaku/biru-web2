# -*- encoding:utf-8 -*-

require "kconv"
require "thinreports"
require "csv"

class TrustManagementsController < ApplicationController
  before_action :search_init, except: [ "trust_user_report" ]

  #-------------------------------------------------------------------------------
  # popup_owner#managements_controllerなど外部から利用することもあるのでクラスメソッド化
  #-------------------------------------------------------------------------------
  class << self
  # 受託担当者を規定します
  def get_trust_members
    trust_user_hash = {}
    #		trust_user_hash['6365'] = {:name=>'松本', :shop_name => '01東武南'}
    ##		trust_user_hash['6425'] = {:name=>'赤坂', :shop_name => '02東武北'}
    #		trust_user_hash['4743'] = {:name=>'葛貫', :shop_name => '02東武北'}
    #		trust_user_hash['20217'] = {:name=>'南', :shop_name => '03さいたま中央'}
    #		trust_user_hash['5518'] = {:name=>'齋藤', :shop_name => '04さいたま東'}
    ##		trust_user_hash['4917'] = {:name=>'市橋', :shop_name => '05常磐'} 2018.04.07 del
    ##		trust_user_hash['6901'] = {:name=>'河上', :shop_name => '06常磐'} 2016.09.16 del
    ##		trust_user_hash['6418'] = {:name=>'松倉', :shop_name => '07常磐'} 2017.03.26 del
    #		trust_user_hash['2976'] = {:name=>'三富', :shop_name => '06常磐'}
    #  	trust_user_hash['9000'] = {:name=>'宅建協会', :shop_name => '90宅建'}
    #  	trust_user_hash['9002'] = {:name=>'ＨＰ反響', :shop_name => '91反響'}

    BiruUser.where(trust_attack_user_flg: true).each do |user|
      trust_user_hash[user.code] = { name: user.name, shop_name: user.trust_attack_area_name }
    end

    trust_user_hash
  end

    # biru_userからアタックリストで検索できるユーザーを取得し、biru_usersへ格納します。
    def get_attack_list_search_users(biru_user)
      #--------------------------------
      # 権限によって絞り込める人を定義する
      #--------------------------------
      if biru_user.attack_all_search
        # すべて検索OKの時は受託担当者すべてを表示
        trust_user_hash = get_trust_members

        # 取得したハッシュに自分のIDも追加する
        trust_user_hash[biru_user.code.to_s] = { name: biru_user.name, shop_name: "" }

        biru_users = BiruUser.where("code In ( " + trust_user_hash.keys.map { |code| "'" + code.to_s + "'" }.join(",") + ")")
        biru_users << BiruUser.find(biru_user)
      else
        # すべての権限ではない時、ログインユーザ自身とアクセスが許可されたユーザーを取得
        biru_users = []
        biru_users.push(BiruUser.find(biru_user.id))
        TrustAttackPermission.find_all_by_permit_user_id(biru_user.id).each do |permission|
          biru_users.push(BiruUser.find(permission.holder_user_id))
        end
      end

      biru_users
    end

    # trust_user_report画面を開くにあたって、ログインユーザーがアタックリスト保持者当人もしくは権限ユーザーかチェックする
    def check_report_auth(login_user, holder_user)
      # ログインユーザーとアクセス先画面のユーザーが同一ならtrue
      return true if login_user.id == holder_user.id

      # ログインユーザーに特権の権限があればtrue
      return true if login_user.attack_all_search == true

      # アクセス許可テーブルにログインユーザーが入っていればtrue
      if TrustAttackPermission.find_by_holder_user_id_and_permit_user_id(holder_user.id, login_user.id)
        return true
      end

      false
    end
  end

  # アタックリストで貸主を新規作成します
  def popup_owner_create
    if params[:owner_name]

      # ログインユーザーに紐づく検索可能ユーザーを指定
      @biru_users = TrustManagementsController.get_attack_list_search_users(@biru_user)
      owner_list = Owner.joins(:biru_user).where("biru_user_id in (?)", @biru_users).select("'<a href=''javascript:win_owner( ' + convert(nvarchar, owners.id) + ');'' style=""text-decoration:underline"">' + owners.name + '</a>' as owner_name, owners.kana as owner_kana, owners.address as owner_address,  owners.tel as owner_tel, biru_users.name as biru_user_name")

      if params[:owner_name].length > 0
        owner_list = owner_list.where("owners.name like '%" + params[:owner_name] + "%'")
      end

      if params[:owner_kana] && params[:owner_kana].length > 0
        owner_list = owner_list.where("owners.kana like '%" + params[:owner_kana] + "%'")
      end

      if params[:owner_address] && params[:owner_address].length > 0
        owner_list = owner_list.where("owners.address like '%" + params[:owner_address] + "%'")
      end

      if params[:owner_tel] && params[:owner_tel].length > 0
        owner_list = owner_list.where("owners.tel like '%" + params[:owner_tel] + "%'")
      end

      gon.owner_list = owner_list
      @search_owner_name = params[:owner_name]
      @search_owner_kana = params[:owner_kana]
      @search_owner_address = params[:owner_address]
      @search_owner_tel = params[:owner_tel]
    else
      gon.owner_list = []
    end

    @header_hidden = true
  end

  # アタックリストの貸主に建物を紐付けるための検索画面を表示します。
  def popup_owner_buildings
    @owner = Owner.find(params[:owner_id])

    if @owner.trusts
      @buildings = []

      # @owner.trusts.each do |trust|
      #   @buildings.push(trust.building) if trust.building
      # end

    end


    @market_radio_flg = false

    if params[:building_name]
      # 検索条件が存在した時、検索

      if params[:market_radio] == "off"

        # ログインユーザーに紐づく検索可能ユーザーを指定
        @biru_users = TrustManagementsController.get_attack_list_search_users(@biru_user)
        building_list = Building.joins(:biru_user).joins(:shop).where("biru_user_id in (?)", @biru_users).select("'<a href=''javascript:trust_create( #{@owner.id}, ' + convert(nvarchar, buildings.id) + ',#{@biru_user.id});'' style=""text-decoration:underline"">' + buildings.name + '</a>' as building_name, buildings.address as building_address, shops.name as shop_name, biru_users.name as biru_user_name, case buildings.selective_type when 0 then '-' when 1 then '重点' when 2 then '準重点' else '不明' end as selectively  ")

        @market_radio_flg = false
      else
        building_list = Building.where(market_flg: true).select("'<a href=''javascript:trust_create( #{@owner.id}, ' + convert(nvarchar, buildings.id) + ',#{@biru_user.id});'' style=""text-decoration:underline"">' + buildings.name + '</a>' as building_name, buildings.address as building_address, 'マーケット' as shop_name, 'マーケット' as biru_user_name, case buildings.selective_type when 0 then '-' when 1 then '重点' when 2 then '準重点' else '不明' end as selectively  ")
        @market_radio_flg = true

      end


      if params[:building_name].length > 0
        building_list = building_list.where("buildings.name like '%" + params[:building_name] + "%'")
      end

      if params[:building_address] && params[:building_address].length > 0
        building_list = building_list.where("buildings.address like '%" + params[:building_address] + "%'")
      end

      gon.building_list = building_list
      @search_building_name = params[:building_name]
      @search_building_address = params[:building_address]

    else
      gon.building_list = []
    end

    @header_hidden = true
  end


  # 受託行動レポート情報を生成します
  def generate_report_info(month, user, area_name)
    # 来月度を取得
    tmp_month = Date.parse(month + "01", "YYYYMMDD").next_month
    month_next = "%04d%02d"%[ tmp_month.year, tmp_month.month ]

    # 前月度を取得
    tmp_month =Date.parse(month + "01", "YYYYMMDD").prev_month
    month_prev = "%04d%02d"%[ tmp_month.year, tmp_month.month ]

    # 今月の集計期間を取得
    start_date = Date.parse(Date.parse(month + "01").prev_month.strftime("%Y%m")+"21")
    end_date= Date.parse(month + "20")

    # 当月の計画・実績データを取得
    biru_user_monthly = BiruUserMonthly.find_by_biru_user_id_and_month(user.id, month)
    unless biru_user_monthly
      biru_user_monthly = BiruUserMonthly.new
    end
    biru_user_monthly.biru_user_id = user.id
    biru_user_monthly.month = month

    # 来月の計画・実績データを取得
    biru_user_monthly_next = BiruUserMonthly.find_by_biru_user_id_and_month(user.id, month_next)
    unless biru_user_monthly_next
      biru_user_monthly_next = BiruUserMonthly.new
    end
    biru_user_monthly_next.biru_user_id = user.id
    biru_user_monthly_next.month = month_next


    # 登録用のデータ
    report = TrustAttackMonthReport.find_or_create_by_month_and_biru_user_id(month, user.id)

    #####################################
    # 当月に訪問した貸主を表示
    # DMアプローチした貸主を表示
    # ＴＥＬアプローチした貸主を表示
    #####################################
    visit_num_all = 0
    visit_num_meet = 0
    visit_num_suggestion = 0

    dm_num_send = 0
    dm_num_recv = 0

    tel_num_call = 0
    tel_num_talk = 0

    # 履歴情報の初期化
    TrustAttackMonthReportAction.unscoped.where("trust_attack_month_report_id = ? ", report.id).update_all(delete_flg: true)
    OwnerApproach.joins(:approach_kind).where("approach_date between ? and ? ", start_date, end_date).where("biru_user_id = ?", user.id).select("owner_approaches.owner_id, approach_kinds.code, approach_kinds.name, owner_approaches.id as approach_id").each do |rec|
      attack_action = TrustAttackMonthReportAction.unscoped.find_or_create_by_trust_attack_month_report_id_and_owner_approach_id(report.id, rec.approach_id)
      attack_action.trust_attack_month_report_id = report.id
      attack_action.owner_approach_id = rec.approach_id

      # 2017/01/09 add
      unless rec.owner
          p "メソッド：generate_report_info error オーナーレコードなし:スキップします：↓"
          p rec
          next
      end

      attack_action.owner_id = rec.owner.id
      attack_action.owner_code = rec.owner.code
      attack_action.owner_name = rec.owner.name
      attack_action.owner_address = rec.owner.address
      attack_action.owner_latitude = rec.owner.latitude
      attack_action.owner_longitude = rec.owner.longitude


      owner_approach = OwnerApproach.find(rec.approach_id)
      attack_action.content = owner_approach.content
      attack_action.approach_date = owner_approach.approach_date
      attack_action.approach_kind_id = owner_approach.approach_kind_id
      attack_action.approach_kind_code = rec.code
      attack_action.approach_kind_name = rec.name

      attack_action.delete_flg = false
      attack_action.save!

      case rec.code
      when "0010", "0020", "0025" then
        ########## 訪問・面談・提案 ###########
        if rec.code == "0010"
          # 留守
          visit_num_all = visit_num_all + 1
        elsif rec.code == "0020"
          # 面談
          visit_num_all = visit_num_all + 1
          visit_num_meet = visit_num_meet + 1
        elsif rec.code == "0025"
          # 提案
          visit_num_all = visit_num_all + 1
          visit_num_meet = visit_num_meet + 1
          visit_num_suggestion = visit_num_suggestion + 1
        end

      when "0030", "0035" then
        ########## DM・DM反響 ###########
        if rec.code == "0030"
          # DM送付
          dm_num_send = dm_num_send + 1
        elsif rec.code == "0035"
          # DM反響
          dm_num_recv = dm_num_recv + 1
        end

      when "0040", "0045" then
        ########## TEL・TEL会話 ###########
        # ＤＭの反響だった時
        if rec.code == "0040"
          tel_num_call = tel_num_call + 1
        elsif rec.code == "0045"
          tel_num_call = tel_num_call + 1
          tel_num_talk = tel_num_talk + 1
        end

      else
        # それ以外のとき
      end
    end

    ##################################################
    # DM発送からTELアプローチした数　及びその平均日数を求める
    ##################################################
    dm_to_tel_cnt_both = 0 # 電話(留守)、電話(会話)
    dm_to_tel_cnt = 0      # 電話(会話)のみ
    dm_to_tel_days = 0     # 電話(会話)が成立した時の平均日数


    OwnerApproach.joins(:approach_kind).where("approach_date between ? and ? ", start_date, end_date).where("biru_user_id = ?", user.id).where("approach_kinds.code = '0030'").group("owner_approaches.owner_id").select("owner_approaches.owner_id, min(approach_date) as min_date").each do |rec|
      # 指定したオーナー、ユーザー、でDM発送日以降〜指定期間以内にTELアプローチ『電話(留守)、電話(会話)』両方の時の件数
      OwnerApproach.joins(:approach_kind).where("approach_date between ? and ? ", rec.min_date, end_date).where("biru_user_id = ?", user.id).where("approach_kinds.code IN ('0040','0045')").where("owner_id = ?", rec.owner_id).group("owner_approaches.owner_id").select(" min(approach_date) as min_date").each do |rec_2|
        dm_to_tel_cnt_both += 1
      end

      # 指定したオーナー、ユーザー、でDM発送日以降〜指定期間以内にTELアプローチ会話した件数・平均日数を求める（アプローチ日を求めるため、上のクエリと共有はできない）
      OwnerApproach.joins(:approach_kind).where("approach_date between ? and ? ", rec.min_date, end_date).where("biru_user_id = ?", user.id).where("approach_kinds.code = '0045'").where("owner_id = ?", rec.owner_id).group("owner_approaches.owner_id").select(" min(approach_date) as min_date").each do |rec_2|
          # 会話した時のみ
          dm_to_tel_cnt += 1
          dm_to_tel_days += (DateTime.parse(rec_2.min_date) - DateTime.parse(rec.min_date)).to_i
      end
    end

    #####################################
    # 成約した物件、見込みが高い物件を表示
    #####################################
    trust_num = 0
    trust_num_oneself = 0

    # 件数のカウント
    rank_s = 0
    rank_a = 0
    rank_b = 0
    rank_c = 0
    rank_d = 0
    rank_w = 0
    rank_x = 0
    rank_y = 0
    rank_z = 0

    rank_approach_cnt = { "S"=>0, "A"=>0, "B"=>0, "C"=>0, "Z"=>0 }
    TrustAttackMonthReportRank.unscoped.where("trust_attack_month_report_id = ? ", report.id).update_all(delete_flg: true)
    order_hash = TrustAttackStateHistory.joins(:trust).joins(:attack_state_to).where("month <= ?", month).where("trusts.biru_user_id = ?", user.id).where("trusts.delete_flg = ?", 0).group("trusts.id").maximum("month")
    order_hash.keys.each do |trust_id|
      # trust_idにはidが、order_hash[trust_id]にはその月の最大月数が入っている
      trust_attack_history = TrustAttackStateHistory.find_by_trust_id_and_month(trust_id, order_hash[trust_id])

      # ↓見込みランクの絞り込みはクエリのwhere句の中でなく、集計結果に対して行う。
      # where句でやるとそのランクがある中での最大をとってしまうので、仮にその後に別のランクが登録されていたら本来は必要ないのにそのレコードがとれてしまうから
      case trust_attack_history.attack_state_to.code
      when "S", "A", "B", "C", "Z"
        # 見込みランクがS・A・B・C・Zのいずれかの時はランク出力対象として保存

        if trust_attack_history.attack_state_to.code == "Z" && trust_attack_history.month.to_s != month.to_s
          # Zランクでも、当月にZランクになったものでなければ出力対象外
        else
          report_rank_regist(report, trust_attack_history, start_date, end_date, rank_approach_cnt)
        end

      else
        # 上記のランク以外でも、今月度にランクの変更があったものは出力対象として保存する。
        if trust_attack_history.month.to_s == month.to_s
          report_rank_regist(report, trust_attack_history, start_date, end_date, rank_approach_cnt)
        end
      end

      case trust_attack_history.attack_state_to.code
      when "S" then
        rank_s = rank_s + 1
      when "A" then
        rank_a = rank_a + 1
      when "B" then
        rank_b = rank_b + 1
      when "C" then
        rank_c = rank_c + 1
      when "D" then
        rank_d = rank_d + 1
      when "W" then
        rank_w = rank_w + 1
      when "X" then
        rank_x = rank_x + 1
      when "Y" then
        rank_y = rank_y + 1
      when "Z" then

        # 成約になった物件は、当月のみ集計対象
        if trust_attack_history.month.to_s == month.to_s

          unless trust_attack_history.manage_type
            p "不正な「trust_attack_history.manage_type.code」です。【trust_attack_history.id:" + trust_attack_history.id.to_s + "】"
          else

            # 件数カウント
            rank_z = rank_z + 1

            # B管理以上が集計対象
            if [ "3", "4", "5", "6", "7", "8", "9", "30", "31", "32", "34", "39", "60", "61", "70", "71", "72" ].include?(trust_attack_history.manage_type.code)

              # 自社・他社の判定
              if trust_attack_history.trust_oneself == true
                trust_num_oneself = trust_num_oneself + trust_attack_history.room_num
              else
                trust_num = trust_num + trust_attack_history.room_num
              end

            end

          end

        end

      else

      end
    end

    ################################################################
    # 受託申請システムから、今月度に成績としてカウントした申請を取得
    ################################################################
    summary_yourself_num = 0
    summary_oneself_num = 0
    summary_point = 0

    # 指定したユーザ・月度の実績を初期化
    TrustAttackMonthReportResult.unscoped.where("trust_attack_month_report_id = ? ", report.id).update_all(delete_flg: true)

    # 受託申請から指定した月度・ユーザの情報を取得
    sql = ""
    sql = sql + "SELECT "
    sql = sql + " ヘッダ.申請ID "
    sql = sql + ",ヘッダ.カウント年月 "
    sql = sql + ",成績.社員番号 "
    sql = sql + ",自他区分 "
    sql = sql + ",SUM(成績.ポイント) AS ポイント合計 "
    sql = sql + ",SUM(成績.戸数) AS 戸数合計 "
    sql = sql + ",ヘッダ.建物名_申請時 "
    sql = sql + ",ヘッダ.営業所名_申請時 "
    sql = sql + ",MAX(備考) 備考トップ "
    sql = sql + " FROM [BIRU10].[biru].[T_受託申請_成績] 成績 "
    sql = sql + " INNER JOIN [BIRU10].[biru].[T_受託申請_ヘッダ] ヘッダ ON 成績.申請ID = ヘッダ.申請ID "
    sql = sql + " WHERE 1=1 "
    sql = sql + " AND 社員番号 = '" + ("00000" + user.code)[-5, 5]  + "' "
    sql = sql + " AND ヘッダ.カウント年月 = '" + month + "' "
    sql = sql + " AND ヘッダ.申請状態 > 1 "
    sql = sql + " AND ヘッダ.削除フラグ = 0 "
    sql = sql + " GROUP BY ヘッダ.申請ID, 成績.社員番号,ヘッダ.カウント年月, 自他区分, ヘッダ.建物名_申請時, ヘッダ.営業所名_申請時 "

    ActiveRecord::Base.connection.select_all(sql).each do |rec|
      trust_attack_month_report_result = TrustAttackMonthReportResult.unscoped.find_or_create_by_trust_attack_month_report_id_and_trust_apply_code(report.id, rec["申請ID"])
      trust_attack_month_report_result.trust_attack_month_report_id = report.id
      trust_attack_month_report_result.delete_flg = 0
      trust_attack_month_report_result.trust_apply_code = rec["申請ID"]
      trust_attack_month_report_result.shop_name = rec["営業所名_申請時"]
      trust_attack_month_report_result.building_name = rec["建物名_申請時"]

      if rec["自他区分"] == 1
        trust_attack_month_report_result.yourself_num = rec["戸数合計"]
        trust_attack_month_report_result.oneself_num = 0
      else
        trust_attack_month_report_result.yourself_num = 0
        trust_attack_month_report_result.oneself_num = rec["戸数合計"]
      end

      trust_attack_month_report_result.point = rec["ポイント合計"]
      trust_attack_month_report_result.save!

      # 合計用
      summary_yourself_num += trust_attack_month_report_result.yourself_num
      summary_oneself_num += trust_attack_month_report_result.oneself_num
      summary_point += trust_attack_month_report_result.point
    end

    #########################
    # レポートデータの保存
    #########################
    report.month = month
    report.biru_user_id = user.id
    report.biru_usr_name = user.name
    report.area_name = area_name
    report.trust_report_url = "trust_user_report?sid=" + user.id.to_s
    report.attack_list_url = "owner_building_list?sid=" + user.id.to_s

    report.visit_plan = biru_user_monthly.trust_plan_visit
    report.visit_num_all = visit_num_all
    report.visit_num_meet = visit_num_meet

    # 2016.05.04 add 面談目標、訪問面談率
    if report.visit_plan
      report.visit_meet_plan = report.visit_plan * 0.65
    end

    if report.visit_num_all > 0
      report.visit_meet_par =  (report.visit_num_meet / report.visit_num_all.to_f).round(3) * 100
    else
      report.visit_meet_par = 0
    end

    report.dm_plan = biru_user_monthly.trust_plan_dm
    report.dm_num_send = dm_num_send
    report.dm_num_recv = dm_num_recv

    report.tel_plan = biru_user_monthly.trust_plan_tel
    report.tel_num_call = tel_num_call
    report.tel_num_talk = tel_num_talk

    report.suggestion_plan = biru_user_monthly.trust_plan_suggestion
    report.suggestion_num = visit_num_suggestion
    report.trust_plan = biru_user_monthly.trust_plan_contract
    report.trust_num = trust_num
    report.trust_num_jisya = trust_num_oneself

    report.rank_s = rank_s
    report.rank_a = rank_a
    report.rank_b = rank_b
    report.rank_c = rank_c
    report.rank_d = rank_d
    report.rank_c_over = rank_s + rank_a + rank_b + rank_c
    report.rank_d_over = rank_s + rank_a + rank_b + rank_c + rank_d

    report.rank_w = rank_w
    report.rank_x = rank_x
    report.rank_y = rank_y
    report.rank_z = rank_z

    # 全件数を取得する
    sql = ""
    sql = sql + "SELECT count(*) as cnt "
    sql = sql + "FROM (" + get_trust_sql(user, "", false) + ") X "
    sql = sql + "where biru_user_id = " + user.id.to_s
    ActiveRecord::Base.connection.select_all(sql).each do |all_cnt_rec|
      report.rank_all = all_cnt_rec["cnt"]
    end

    ##########################
    # 先月からのランク増減を保存
    ##########################
    report_prev = TrustAttackMonthReport.find_or_initialize_by_month_and_biru_user_id(month_prev, user.id)
    report.fluctuate_s =  report.rank_s - nz(report_prev.rank_s)
    report.fluctuate_a =  report.rank_a - nz(report_prev.rank_a)
    report.fluctuate_b =  report.rank_b - nz(report_prev.rank_b)
    report.fluctuate_c =  report.rank_c - nz(report_prev.rank_c)
    report.fluctuate_d =  report.rank_d - nz(report_prev.rank_d)
    report.fluctuate_w =  report.rank_w - nz(report_prev.rank_w)
    report.fluctuate_x =  report.rank_x - nz(report_prev.rank_x)
    report.fluctuate_y =  report.rank_y - nz(report_prev.rank_y)
    report.fluctuate_z =  report.rank_z - nz(report_prev.rank_z)

    ###########################################
    # DM発送後のTEL および　そこまでの平均日数を取得
    ###########################################
    report.dm_to_tel_plan = (dm_num_send * 0.1).to_i
    report.dm_to_tel_result = dm_to_tel_cnt
    report.dm_to_tel_result_both = dm_to_tel_cnt_both

    if dm_to_tel_cnt > 0
      report.dm_to_tel_average = (dm_to_tel_days/dm_to_tel_cnt.to_f).round(1)
    else
      report.dm_to_tel_average = 0
    end

    ##########################################
    # 見込みランク別の今月のアプローチ件数を表示
    ##########################################
    report.approach_cnt_s = rank_approach_cnt["S"]
    report.approach_cnt_a = rank_approach_cnt["A"]
    report.approach_cnt_b = rank_approach_cnt["B"]
    report.approach_cnt_c = rank_approach_cnt["C"]
    report.approach_cnt_z = rank_approach_cnt["Z"]


    ##########################################
    # 受託申請システムの集計値を設定
    ##########################################
    report.apply_yourself_num = summary_yourself_num
    report.apply_oneself_num = summary_oneself_num
    report.apply_point = summary_point

    # p report
    report.save!
  end

  # 全件検索
  def search
    #----------------
    # 見込みリスト
    #----------------
    rank_arr = []

    rank_arr.push("Z") if params[:rank_z]
    rank_arr.push("S") if params[:rank_s]
    rank_arr.push("A") if params[:rank_a]
    rank_arr.push("B") if params[:rank_b]
    rank_arr.push("C") if params[:rank_c]
    rank_arr.push("D") if params[:rank_d]

    if params[:rank_wxy]
       rank_arr.push("W")
       rank_arr.push("X")
       rank_arr.push("Y")
    end

    rank_list = ""
    rank_arr.each do |value|
      if rank_list.length > 0
        rank_list = rank_list + ","
      end
      rank_list = rank_list + "'" + value + "'"
    end

    if params[:owner_name]

      @search_param = params

      if params[:user_id] == ""
        # 指定なしが選択されている時
        @trust_manages = ActiveRecord::Base.connection.select_all(get_trust_sql(@biru_users, rank_list, true, params))
      else
        # 受託担当者が指定されている時
        @trust_manages = ActiveRecord::Base.connection.select_all(get_trust_sql(BiruUser.find(params[:user_id].to_s), rank_list, true, params))
      end

    else
      @trust_manages = []
    end

    gon.trust_manages = @trust_manages
  end


  # 貸主情報画面から委託契約（見込みランク）の更新
  def popup_owner_trust_update
    pri_trust_attack_update(params[:trust][:id],  params[:month], params[:before_attack_state_id], params[:trust][:attack_state_id], params[:room_num], params[:history][:manage_type], params[:history][:oneself])
    redirect_to action: "popup_owner", controller: "managements",  id: @trust.owner_id
  end

  # 貸主情報画面から指定した委託CDの主担当者のユーザを変更
  def popup_owner_trust_change_user
    trust = Trust.find(params[:trust][:id])
    trust.biru_user_id = params[:user_id]
    trust.save!

    redirect_to action: "popup_owner", controller: "managements",  id: trust.owner_id
  end

  def pri_trust_attack_update(trust_id, month, before_attack_state_id, after_attack_state_id, room_num, manage_type_id, onself_type)
    @trust = Trust.find(trust_id)

    # 指定された年月のbefore/afterの登録を行う
    history = TrustAttackStateHistory.find_or_create_by_trust_id_and_month(@trust.id, month)
    history.trust_id = @trust.id
    history.month = month
    history.attack_state_from_id = before_attack_state_id
    history.attack_state_to_id = after_attack_state_id

    history.room_num = room_num
    history.manage_type_id = manage_type_id

    # 自他区分を設定
    if onself_type == "yourself"
      history.trust_oneself = false
    elsif onself_type  == "oneself"
      history.trust_oneself = true
    else
      history.trust_oneself = nil
    end

    history.save!

    # 指定された年月が登録済み履歴の中で最新だった時、委託のランクも更新
    max_month =  TrustAttackStateHistory.where("trust_id = ?", @trust.id).maximum("month")
    if month == max_month.to_s
      @trust.attack_state_id = after_attack_state_id
      @trust.save!
    end
  end


  # def get_trust_data()
  def get_trust_sql(object_user, rank_list, order_flg, search_params = nil)
    # trustについているdelete_flg の　default_scopeの副作用で、biru_usersのLEFT_OUTER_JOINが効かなくなっている？（空白のものは出てこない・・）なのでそうであればINNER JOINでつないでしまう（2014/07/15）
    # trust_data = Trust.joins(:building => :shop ).joins(:owner).joins(:manage_type).joins("LEFT OUTER JOIN biru_users on trusts.biru_user_id = biru_users.id").where("owners.code is null")
    # trust_data = Trust.joins(:building => :shop ).joins(:owner).joins(:manage_type).joins("LEFT OUTER JOIN biru_users on trusts.biru_user_id = biru_users.id").joins("LEFT OUTER JOIN attack_states on trusts.attack_state_id = attack_states.id").where("owners.code is null")

    # trust_data = Trust.joins(:owner).joins("LEFT OUTER JOIN manage_types ON trusts.manage_type_id = manage_types.id").joins("LEFT OUTER JOIN buildings on trusts.building_id = buildings.id").joins("LEFT OUTER JOIN shops on buildings.shop_id = shops.id").joins("LEFT OUTER JOIN biru_users on trusts.biru_user_id = biru_users.id").joins("LEFT OUTER JOIN attack_states on trusts.attack_state_id = attack_states.id").where("owners.code is null")

    # ユーザーが複数指定されているか判定
    if object_user.kind_of?(BiruUser)
      biru_user_id = object_user.id.to_s
      arr_flg = false
    else

      biru_user_ids = []
      object_user.each do |biru|
        biru_user_ids.push(biru.id)
      end


      arr_flg = true
    end

    # 指定した列のハッシュだけで返す為に直接SQLを実行する
    sql = ""
    sql = sql + " SELECT trusts.id as trust_id "
    sql = sql + " , trusts.biru_user_id as biru_user_id "
    sql = sql + " , trusts.manage_type_id as trust_manage_type_id "
    sql = sql + " , owners.id as owner_id "
    sql = sql + " , owners.attack_code as owner_attack_code "
    sql = sql + " , owners.name as owner_name "
    sql = sql + " , owners.kana as owner_kana "
    sql = sql + " , owners.address as owner_address "
    sql = sql + " , owners.memo as owner_memo "
    sql = sql + " , owners.latitude as owner_latitude "
    sql = sql + " , owners.longitude as owner_longitude "
    sql = sql + " , owners.dm_delivery as owner_dm_delivery "

    sql = sql + " , '<a href=''javascript:win_owner(' + convert(nvarchar, owners.id)  + ');'' style=""text-decoration:underline"">' + owners.name + '</a>' as owner_name_link"

    sql = sql + " , owners.dm_ptn_1 as owner_dm_ptn_1 "
    sql = sql + " , owners.dm_ptn_2 as owner_dm_ptn_2 "
    sql = sql + " , owners.dm_ptn_3 as owner_dm_ptn_3 "
    sql = sql + " , owners.dm_ptn_4 as owner_dm_ptn_4 "

    sql = sql + " , owners.dm_ptn_5 as owner_dm_ptn_5 "
    sql = sql + " , owners.dm_ptn_6 as owner_dm_ptn_6 "
    sql = sql + " , owners.dm_ptn_7 as owner_dm_ptn_7 "
    sql = sql + " , owners.dm_ptn_8 as owner_dm_ptn_8 "

    sql = sql + " , owners.tel as owner_tel "
    sql = sql + " , buildings.id as building_id "
    sql = sql + " , buildings.attack_code as building_attack_code "
    sql = sql + " , buildings.name as building_name "
    sql = sql + " , '<a href=''javascript:win_building(' + convert(nvarchar, buildings.id)  + ');'' style=""text-decoration:underline"">' + buildings.name + '</a>' as building_name_link"
    sql = sql + " , buildings.address as building_address"
    sql = sql + " , buildings.memo as building_memo "
    sql = sql + " , buildings.latitude as building_latitude "
    sql = sql + " , buildings.longitude as building_longitude "
    sql = sql + " , buildings.proprietary_company as building_proprietary_company "
    sql = sql + " , shops.id as shop_id "
    sql = sql + " , shops.name as shop_name "
    sql = sql + " , shops.name as shop_icon "
    sql = sql + " , shops.latitude as shop_latitude "
    sql = sql + " , shops.longitude as shop_longitude "
    sql = sql + " , biru_users.name as biru_user_name "
    sql = sql + " , attack_states.code as attack_states_code "
    sql = sql + " , attack_states.name as attack_states_name "
    # 速度の問題で訪問履歴などの件数は取得しない delete 2015.04.24
    # sql = sql + " , SUM(case approaches.code when '0010' then 1 else 0 end) as visit_rusu "
    # sql = sql + " , SUM(case approaches.code when '0020' then 1 else 0 end) as visit_zai "
    # sql = sql + " , SUM(case approaches.code when '0030' then 1 else 0 end) as dm_send "
    # sql = sql + " , SUM(case approaches.code when '0035' then 1 else 0 end) as dm_res "
    # sql = sql + " , SUM(case approaches.code when '0040' then 1 else 0 end) as tel_call "
    # sql = sql + " , SUM(case approaches.code when '0045' then 1 else 0 end) as tel_speack "
    sql = sql + ", case buildings.selective_type when 1 then '重点' when 2 then '準重点' else '' end as building_selective_type "
    sql = sql + ", occur_sources.name as occur_sources_name "
    sql = sql + " FROM trusts inner join owners on trusts.owner_id = owners.id "
    sql = sql + " inner JOIN manage_types on trusts.manage_type_id = manage_types.id "
    sql = sql + " inner JOIN buildings on trusts.building_id = buildings.id "
    sql = sql + " inner JOIN shops on buildings.shop_id = shops.id "
    sql = sql + " inner JOIN biru_users on trusts.biru_user_id = biru_users.id "
    sql = sql + " left outer JOIN attack_states on trusts.attack_state_id = attack_states.id "
    sql = sql + " left outer JOIN occur_sources on buildings.occur_source_id = occur_sources.id "
    # sql = sql + " left outer JOIN (  "
    # sql = sql + "  select  "
    # sql = sql + "      owner_approaches.owner_id"
    # sql = sql + "     ,owner_approaches.approach_date"
    # sql = sql + "     ,owner_approaches.content"
    # sql = sql + "     ,approach_kinds.code"
    # sql = sql + "     ,approach_kinds.name"
    # sql = sql + "  from owner_approaches inner join approach_kinds on owner_approaches.approach_kind_id = approach_kinds.id"
    # sql = sql + "  where owner_approaches.delete_flg = 0"

    # # if arr_flg
    # #   sql = sql + "   and owner_approaches.biru_user_id In ( " + biru_user_ids.join(',') + ") "
    # # else
    # #   sql = sql + "   and owner_approaches.biru_user_id = " + biru_user_id + " "
    # # end
    # #
    # sql = sql + "  ) approaches on owners.id = approaches.owner_id"
    sql = sql + " WHERE owners.code is null "
    sql = sql + "   AND trusts.delete_flg = 0 "
    sql = sql + "   AND owners.delete_flg = 0 "
    sql = sql + "   AND buildings.delete_flg = 0 "

    # ランク指定がある場合、そのランクのみ表示
    if rank_list.length > 0
      sql = sql + " AND  attack_states.code IN (" + rank_list + ") "
    end

    #  # ログインユーザーが支店長権限があればすべての物件を表示。そうでなければ受託担当者の管理する物件のみを表示する。
    #  unless @biru_user.attack_all_search
    #    #trust_data = trust_data.where('trusts.biru_user_id = ?', @biru_user.id)
    #    sql = sql + " AND trusts.biru_user_id = " + @biru_user.id.to_s
    #  end

    if arr_flg
      sql = sql + " AND trusts.biru_user_id In ( " + biru_user_ids.join(",") + ") "
    else
      sql = sql + " AND trusts.biru_user_id = " + biru_user_id + " "
    end


    #----------------------------------#
    # 検索条件が指定されている時の絞り込み①
    #----------------------------------#
    if search_params

      # 貸主名
      if search_params[:owner_name].length > 0
        sql = sql + " AND owners.name like '%" + search_params[:owner_name].gsub("'", "").gsub(";", "") + "%' "
      end

      # 物件名
      if search_params[:building_name].length > 0
        sql = sql + " AND buildings.name like '%" + search_params[:building_name].gsub("'", "").gsub(";", "") + "%' "
      end


      # 貸主住所
      if search_params[:owner_address].length > 0
        sql = sql + " AND owners.address like '%" + search_params[:owner_address].gsub("'", "").gsub(";", "") + "%' "
      end

      # 建物住所
      if search_params[:building_address].length > 0
        sql = sql + " AND buildings.address like '%" + search_params[:building_address].gsub("'", "").gsub(";", "") + "%' "
      end


      # 貸主メモ
      if search_params[:owner_memo].length > 0
        sql = sql + " AND owners.memo like '%" + search_params[:owner_memo].gsub("'", "").gsub(";", "") + "%' "
      end

      # 建物メモ
      if search_params[:building_memo].length > 0
        sql = sql + " AND buildings.memo like '%" + search_params[:building_memo].gsub("'", "").gsub(";", "") + "%' "
      end

      # 現管理会社
      if search_params[:building_proprietary_company].length > 0
        sql = sql + " AND buildings.proprietary_company like '%" + search_params[:building_proprietary_company].gsub("'", "").gsub(";", "") + "%' "
      end

      # 管理営業所
      if search_params[:shop_id].to_s.length > 0
        sql = sql + " AND shops.id = " + search_params[:shop_id] + " "
      end

      # 重点地域・準重点地域
      if search_params[:selective_first] || search_params[:selective_second]

        tmp_selective_list = ""
        if search_params[:selective_first]
          tmp_selective_list = "1"
        end

        if search_params[:selective_second]

          if tmp_selective_list.length > 0
            tmp_selective_list += ","
          end

          tmp_selective_list += "2"
        end

        sql = sql + " AND buildings.selective_type IN ( " + tmp_selective_list + ") "
      end

      # 反響
      if search_params[:occur_source_id].to_s.length > 0
        sql = sql + " AND buildings.occur_source_id = " + search_params[:occur_source_id] + " "
      end

    end


    #----------------------------------#
    # 検索条件が指定されている時の絞り込み②
    #----------------------------------#

    arr_exist = []
    arr_exist.push(99999)
    filter_exist_flg = false

    arr_not_exist = []
    arr_not_exist.push(99999)
    filter_not_exist_flg = false

    # 訪問リレキのチェック
    if @history_visit

      unless @history_visit[:all]

        # 訪問リレキで「すべて」以外が選択されているとき
        # approaches = OwnerApproach.joins(:approach_kind).where("approach_kinds.code IN ('0010', '0020')").where("approach_date between ? and ? ", Date.parse(@history_visit_from), Date.parse(@history_visit_to))

        # if @history_visit[:exist]
        #   approaches.each do |approach|
        #     arr_exist.push(approach.owner_id)
        #   end
        #   filter_exist_flg = true
        #
        # elsif @history_visit[:not_exist]
        #   approaches.each do |approach|
        #     arr_not_exist.push(approach.owner_id)
        #   end
        #   filter_not_exist_flg = true
        # end

        if @history_visit[:exist]
          kinds = ApproachKind.find_all_by_code([ "0010", "0020" ])
          sql = sql + " AND owners.id IN ( select owner_id from owner_approaches where delete_flg = 0 and approach_kind_id In ( " + kinds.map { |kind| kind.id }.join(",") +  " ) and approach_date between '" + Date.parse(@history_visit_from).strftime("%Y-%m-%d") + "' and  '" + Date.parse(@history_visit_to).strftime("%Y-%m-%d") + "') "
        end

      end

    end



    # DMリレキのチェック
    if @history_dm

      unless @history_dm[:all]

        # # DMリレキで「すべて」以外が選択されているとき
        # approaches = OwnerApproach.joins(:approach_kind).where("approach_kinds.code IN ('0030','0035')").where("approach_date between ? and ? ", Date.parse(@history_dm_from), Date.parse(@history_dm_to))
        #
        # if @history_dm[:exist]
        #   approaches.each do |approach|
        #     arr_exist.push(approach.owner_id)
        #   end
        #   filter_exist_flg = true
        #
        # elsif @history_dm[:not_exist]
        #   approaches.each do |approach|
        #     arr_not_exist.push(approach.owner_id)
        #   end
        #   filter_not_exist_flg = true
        #
        # end

        if @history_dm[:exist]
          kinds = ApproachKind.find_all_by_code([ "0030", "0035" ])
          sql = sql + " AND owners.id IN ( select owner_id from owner_approaches where delete_flg = 0 and approach_kind_id In ( " + kinds.map { |kind| kind.id }.join(",") +  " ) and approach_date between '" + Date.parse(@history_dm_from).strftime("%Y-%m-%d") + "' and  '" + Date.parse(@history_dm_to).strftime("%Y-%m-%d") + "') "
        end
      end


    end

    # TELリレキのチェック
    if @history_tel
      unless @history_tel[:all]

        # # TELリレキで「すべて」以外が選択されているとき
        # approaches = OwnerApproach.joins(:approach_kind).where("approach_kinds.code IN ('0040','0045')").where("approach_date between ? and ? ", Date.parse(@history_tel_from), Date.parse(@history_tel_to))
        #
        # if @history_tel[:exist]
        #   approaches.each do |approach|
        #     arr_exist.push(approach.owner_id)
        #   end
        #   filter_exist_flg = true
        #
        # elsif @history_tel[:not_exist]
        #   approaches.each do |approach|
        #     arr_not_exist.push(approach.owner_id)
        #   end
        #   filter_not_exist_flg = true
        # end

        if @history_tel[:exist]

          kinds = ApproachKind.find_all_by_code([ "0040", "0045" ])
          sql = sql + " AND owners.id IN ( select owner_id from owner_approaches where delete_flg = 0 and approach_kind_id In ( " + kinds.map { |kind| kind.id }.join(",") +  " ) and approach_date between '" + Date.parse(@history_tel_from).strftime("%Y-%m-%d") + "' and  '" + Date.parse(@history_tel_to).strftime("%Y-%m-%d") + "') "
        end
      end

    end


    # # 絞り込み条件が指定されていた時
    # if filter_exist_flg
    #     # trust_data = trust_data.where("owners.id in (?)", arr_exist)
    #     sql = sql + " AND owners.id in (" + arr_exist.join(',') + ") "
    # end
    #
    # if filter_not_exist_flg
    #   # trust_data = trust_data.where("owners.id not in (?)", arr_not_exist)
    #   sql = sql + "AND owners.id not in (" + arr_not_exist.join(',') + ") "
    # end


    sql = sql + " group by trusts.manage_type_id  "
    sql = sql + " , owners.id  "
    sql = sql + " , trusts.id  "
    sql = sql + " , owners.attack_code  "
    sql = sql + " , owners.name  "
    sql = sql + " , owners.kana  "
    sql = sql + " , owners.address  "
    sql = sql + " , owners.memo  "
    sql = sql + " , owners.latitude  "
    sql = sql + " , owners.longitude  "
    sql = sql + " , owners.dm_delivery  "
    sql = sql + " , owners.tel  "
    sql = sql + " , buildings.id  "
    sql = sql + " , buildings.attack_code  "
    sql = sql + " , buildings.name  "
    sql = sql + " , buildings.address  "
    sql = sql + " , buildings.selective_type  "
    sql = sql + " , buildings.memo  "
    sql = sql + " , buildings.latitude  "
    sql = sql + " , buildings.longitude  "
    sql = sql + " , buildings.proprietary_company  "
    sql = sql + " , shops.id  "
    sql = sql + " , shops.name  "
    sql = sql + " , shops.name  "
    sql = sql + " , shops.latitude  "
    sql = sql + " , shops.longitude  "
    sql = sql + " , biru_users.name  "
    sql = sql + " , attack_states.name  "
    sql = sql + " , attack_states.code  "
    sql = sql + " , occur_sources.name  "
    sql = sql + " , trusts.biru_user_id  "
    sql = sql + " , owners.dm_ptn_1 "
    sql = sql + " , owners.dm_ptn_2 "
    sql = sql + " , owners.dm_ptn_3 "
    sql = sql + " , owners.dm_ptn_4 "
    sql = sql + " , owners.dm_ptn_5 "
    sql = sql + " , owners.dm_ptn_6 "
    sql = sql + " , owners.dm_ptn_7 "
    sql = sql + " , owners.dm_ptn_8 "


    # 複数指定
    if order_flg
      # sql = sql + " ORDER BY buildings.id asc"
      sql = sql + " ORDER BY owners.id asc"
    end

    sql
  end



  def index
    @month = ""
    if params[:month]
      @month = params[:month]
    else
      @month = get_cur_month
    end

    # 最新の実行結果より先のものが指定された時、最新の月度で表示する。
    maxmonth = TrustAttackMonthReport.maximum(:month)
    if @month > maxmonth
      @month = maxmonth
    end

    dt_base = Date.parse(@month + "01", "YYYYMMDD").months_ago(5)

    @calender = []
    10.times {
      @calender.push([ dt_base.strftime("%Y/%m"), dt_base.strftime("%Y%m") ])
      dt_base = dt_base.next_month
    }

    user_list = []

    # 受託担当者のリスト(TrustAttackMonthReportに登録されている情報から取得)
    # trust_user_hash = get_trust_members
    trust_user_hash = {}
    graph_categories = []

    # DM発送後の会話率
    graph_dm_to_tel_categories = []
    graph_dm_to_tel_plan = []
    graph_dm_to_tel_result = []
    graph_dm_to_tel_result_both = []

    # 訪問の計画実績面談率
    graph_visit_plan = []
    graph_visit_result = []
    graph_visit_meet = []

    # TELアプローチ
    graph_tel_plan = []
    graph_tel_call = []
    graph_tel_talk = []

    # ランクアップ
    graph_rankup_s = []
    graph_rankup_a = []
    graph_rankup_b = []
    graph_rankup_c = []

    TrustAttackMonthReport.where(month: @month).order(:area_name).each do |trust_attack_month_report|
      trust_user = trust_attack_month_report.biru_user
      trust_user_hash[trust_user.code] = { shop_name: trust_attack_month_report.area_name }

      graph_categories.push(trust_user.name)

      # DM発送後のTELアプローチ
      if trust_attack_month_report.dm_to_tel_average
      graph_dm_to_tel_categories.push(trust_user.name + "<br/>(平均TEL間隔 " + (trust_attack_month_report.dm_to_tel_average.round(2)).to_s + " 日)")
      else
        graph_dm_to_tel_categories.push(trust_user.name + "<br/>(平均TEL間隔 - 日)")
      end
      graph_dm_to_tel_plan.push(trust_attack_month_report.dm_to_tel_plan)
      graph_dm_to_tel_result.push(trust_attack_month_report.dm_to_tel_result)
      graph_dm_to_tel_result_both.push(trust_attack_month_report.dm_to_tel_result_both)

      # 訪問の計画実績面談率
      graph_visit_plan.push(trust_attack_month_report.visit_plan)
      graph_visit_result.push(trust_attack_month_report.visit_num_all)
      graph_visit_meet.push(trust_attack_month_report.visit_num_meet)

      # TELアプローチ
      graph_tel_plan.push(trust_attack_month_report.tel_plan)
      graph_tel_call.push(trust_attack_month_report.tel_num_call)
      graph_tel_talk.push(trust_attack_month_report.tel_num_talk)

      # ランクアップ
      graph_rankup_s.push(trust_attack_month_report.fluctuate_s)
      graph_rankup_a.push(trust_attack_month_report.fluctuate_a)
      graph_rankup_b.push(trust_attack_month_report.fluctuate_b)
      graph_rankup_c.push(trust_attack_month_report.fluctuate_c)
    end


    # ユーザーを取得
    biru_users = BiruUser.where("code In ( " + trust_user_hash.keys.map { |code| "'" + code.to_s + "'" }.join(",") + ")")
    # 全件件数を取得するためのSQL
    all_cnt_hash = {}
    sql = ""
    sql = sql + "SELECT biru_user_id, count(*) as cnt "
    sql = sql + "FROM (" + get_trust_sql(biru_users, "", false) + ") X "
    sql = sql + "GROUP BY biru_user_id "
    ActiveRecord::Base.connection.select_all(sql).each do |all_cnt_rec|
      all_cnt_hash[BiruUser.find(all_cnt_rec["biru_user_id"]).code] = all_cnt_rec["cnt"]
    end

    trust_user_hash.keys.each do |key|
      rec = {}

      # レポート表示用データ取得
      exist_flg = false
      trust_user = BiruUser.find_by_code(key)
      if trust_user
        # ワークデータで作成済みのデータを取得する
        report = TrustAttackMonthReport.find_by_month_and_biru_user_id(@month, trust_user.id)
        if report
          exist_flg = true
        end
      end

      if exist_flg

        rec["biru_user_id"] = report.biru_user_id.to_s
        rec["biru_usr_name"] = report.biru_usr_name
        rec["shop_name"] = trust_user_hash[key][:shop_name]

        rec["trust_report"] = report.trust_report_url
        rec["attack_list"] = report.attack_list_url

        rec["visit_plan"] = report.visit_plan
        rec["visit_num_all"] = report.visit_num_all
        rec["visit_num_meet"] = report.visit_num_meet

        rec["visit_meet_plan"] = report.visit_meet_plan
        rec["visit_meet_par"] = report.visit_meet_par.round(2) if report.visit_meet_par

        rec["dm_plan"] = report.dm_plan
        rec["dm_num_send"] = report.dm_num_send
        rec["dm_num_recv"] = report.dm_num_recv
        rec["tel_plan"] = report.tel_plan
        rec["tel_num_call"] = report.tel_num_call
        rec["tel_num_talk"] = report.tel_num_talk

        rec["trust_plan"] = report.trust_plan
        rec["trust_num"] = report.trust_num
        rec["suggestion_plan"] = report.suggestion_plan
        rec["suggestion_num"] = report.suggestion_num

        rec["rank_s"] = report.rank_s
        rec["rank_a"] = report.rank_a
        rec["rank_b"] = report.rank_b
        rec["rank_c"] = report.rank_c
        rec["rank_d"] = report.rank_d
        rec["rank_all"] = report.rank_all

        rec["rank_c_over"] = nz(report.rank_s) + nz(report.rank_a) + nz(report.rank_b) + nz(report.rank_c)
        rec["rank_d_over"] = nz(report.rank_s) + nz(report.rank_a) + nz(report.rank_b) + nz(report.rank_c) + nz(report.rank_d)
        rec["rank_etc"] = nz(report.rank_w) + nz(report.rank_x) + nz(report.rank_y) + nz(report.rank_z)

        rec["dm_to_tel_plan"] = report.dm_to_tel_plan
        rec["dm_to_tel_result"] = report.dm_to_tel_result
        rec["dm_to_tel_result_both"] = report.dm_to_tel_result_both

        if report.dm_to_tel_average
        rec["dm_to_tel_average"] = report.dm_to_tel_average.round(2)
        else
          rec["dm_to_tel_average"] = 0
        end

        rec["apply_yourself_num"] = report.apply_yourself_num
        rec["apply_oneself_num"] = report.apply_oneself_num
        rec["apply_point"] = report.apply_point

      else

        rec["biru_user_id"] = 1.to_s
        rec["biru_usr_name"] = "xxx"
        rec["trust_report"] = "trust_user_report?sid=" + 1.to_s
        rec["attack_list"] = "owner_building_list?sid=" + 1.to_s
        # rec['visit_plan'] = 0
        # rec['visit_result'] = 0
        # rec['visit_value'] = 0
        # rec['dm_plan'] = 0
        # rec['dm_result'] = 0
        # rec['dm_value'] = 0
        # rec['tel_plan'] = 0
        # rec['tel_result'] = 0
        # rec['tel_value'] = 0
        # rec['trust_num'] = 0
        # rec['rank_s'] = 0
        # rec['rank_a'] = 0
        # rec['rank_b'] = 0

      end

      user_list.push(rec)
    end

    @data_update = TrustAttackMonthReportUpdateHistory.find_by_month(@month)
    gon.data_list = user_list


    #----------------------------------
    # グラフ作成（DM発送後のTELアプローチ)
    #----------------------------------
    @graph_dm_to_tel = LazyHighCharts::HighChart.new("graph_dm_to_tel") do |f|
      f.title(text: "DM発送後の発送数の10%への会話率")
      f.yAxis(labels: { formatter: 0 }, title: { text: "件" })
      f.xAxis(categories: graph_dm_to_tel_categories, tickInterval: 1) # 1とかは列の間隔の指定

      # 凡例
      f.legend(
          layout: "vertical",
          reversed: false,
          backgroundColor: "#FFFFFF",
          floating: true,
          align: "right",
          x: 0,
          y: 50,
          verticalAlign: "top"
      )

      f.series(name: "DM発送数の10%", data: graph_dm_to_tel_plan, type: "column", color: "#3276b1")
      #      f.series(name: '発送者への電話数(留守・会話)', data: graph_dm_to_tel_result_both, type: "column", color: '#8cc63f')
      f.series(name: "発送者への会話数", data: graph_dm_to_tel_result, type: "column", color: "#d9534f")
    end


    #----------------------------------
    # グラフ作成（訪問)
    #----------------------------------
    @graph_visit = LazyHighCharts::HighChart.new("graph_visit") do |f|
      f.title(text: "訪問")
      f.yAxis(labels: { formatter: 0 }, title: { text: "件" })
      f.xAxis(categories: graph_categories, tickInterval: 1) # 1とかは列の間隔の指定

      # 凡例
      f.legend(
          layout: "vertical",
          reversed: false,
          backgroundColor: "#FFFFFF",
          floating: true,
          align: "right",
          x: 0,
          y: 50,
          verticalAlign: "top"
      )

      f.series(name: "目標", data: graph_visit_plan, type: "column", color: "#3276b1")
      f.series(name: "実績", data: graph_visit_result, type: "column", color: "#d9534f")
      f.series(name: "面談", data: graph_visit_meet, type: "column", color: "#8cc63f")
    end


    #----------------------------------
    # グラフ作成（TELアプローチ)
    #----------------------------------
    @graph_tel = LazyHighCharts::HighChart.new("graph_tel") do |f|
      f.title(text: "電話アプローチ")
      f.yAxis(labels: { formatter: 0 }, title: { text: "件" })
      f.xAxis(categories: graph_categories, tickInterval: 1) # 1とかは列の間隔の指定

      # 凡例
      f.legend(
          layout: "vertical",
          reversed: false,
          backgroundColor: "#FFFFFF",
          floating: true,
          align: "right",
          x: 0,
          y: 50,
          verticalAlign: "top"
      )

      f.series(name: "目標", data: graph_tel_plan, type: "column", color: "#3276b1")
      f.series(name: "実績", data: graph_tel_call, type: "column", color: "#d9534f")
      f.series(name: "会話", data: graph_tel_talk, type: "column", color: "#8cc63f")
    end

    #----------------------------------
    # グラフ作成（ランクアップ)
    #----------------------------------
    @graph_rankup = LazyHighCharts::HighChart.new("graph_rankup") do |f|
      f.title(text: "先月からの見込みランク変動")
      f.yAxis(labels: { formatter: 0 }, title: { text: "件" })
      f.xAxis(categories: graph_categories, tickInterval: 1) # 1とかは列の間隔の指定

      # 凡例
      f.legend(
          layout: "vertical",
          reversed: false,
          backgroundColor: "#FFFFFF",
          floating: true,
          align: "right",
          x: 0,
          y: 50,
          verticalAlign: "top"
      )

      f.series(name: "Sランク", data: graph_rankup_s, type: "column", color: "#3276b1")
      f.series(name: "Aランク", data: graph_rankup_a, type: "column", color: "#d9534f")
      f.series(name: "Bランク", data: graph_rankup_b, type: "column", color: "#8cc63f")
      f.series(name: "Cランク", data: graph_rankup_c, type: "column", color: "#006400")
    end
  end


  def owner_building_list
    # 権限チェック。権限がない人は自分の物件しか見れない
    # unless params[:sid]
    #   @error_msg = "パラメータが不正です。"
    #     else
    #       @object_user = BiruUser.find(params[:sid].to_i)
    #       unless @object_user
    #         @error_msg = "指定されたユーザーが存在しません。"
    #       else
    #         unless TrustManagementsController.check_report_auth(@biru_user, @object_user)
    #       @error_msg = "自分以外のアタックリストにアクセスすることはできません。"
    #         end
    #       end
    # end

    # 2015/08/27 update ログインユーザーが該当する物件にアクセスできるようにする。
    @object_user = @biru_user

    # 見込みランクの指定
    rank_list = ""
    @disp_search = false

    unless params[:owner_name]


      ###############################################
      # 再検索させるように、初期表示のヒットは０件にする。
      ###############################################
      rank_list = "'AA'"
      @disp_search = true
      param_tmp = nil
    else

      param_tmp = params
      @search_param = params

      # アタックリスト一覧から再検索してきた時
      rank_arr = []
      rank_arr.push("S") if params[:rank_s]
      rank_arr.push("A") if params[:rank_a]
      rank_arr.push("B") if params[:rank_b]
      rank_arr.push("C") if params[:rank_c]
      rank_arr.push("D") if params[:rank_d]
      rank_arr.push("W") if params[:rank_w]
      rank_arr.push("X") if params[:rank_x]
      rank_arr.push("Y") if params[:rank_y]
      rank_arr.push("Z") if params[:rank_z]

      rank_arr.each do |value|
        if rank_list.length > 0
          rank_list = rank_list + ","
        end

        rank_list = rank_list + "'" + value + "'"
      end

    end

    @combo_shop = jqgrid_combo_shop


    # 検索条件にエラーが存在しないとき
    if @error_msg.size == 0

      # 貸主新規作成用
      @attack_owner = Owner.new

      tmp_building_id = 0
      building_id_arr = []
      trust_manages = []

      shops = []
      buildings = []
      trusts = []
      owners = []
      owner_to_buildings = {}
      building_to_owners = {}



      if params[:user_id] == nil or params[:user_id] == ""
        # 指定なしが選択されている時
        search_user = @biru_users
      else
        # 受託担当者が指定されている時
        search_user = BiruUser.find(params[:user_id].to_s)
      end

      ActiveRecord::Base.connection.select_all(get_trust_sql(search_user, rank_list, true, param_tmp)).each do |rec|
        # jqgrid用データ
        trust_manages.push(rec)

        # 貸主情報
        owner = {}
        owner[:id] = rec["owner_id"]
        owner[:name] = rec["owner_name"]
        owner[:address] = rec["owner_address"]
        owner[:latitude] = rec["owner_latitude"]
        owner[:longitude] = rec["owner_longitude"]
        owners.push(owner) unless owners.index(owner)

        # 委託情報
        trust = {}
        trust[:owner_id] = rec["owner_id"]
        trust[:building_id] = rec["building_id"]
        trust[:manage_type_id] = rec[:trust_manage_type_id]
        trust[:attack_states_code] = rec["attack_states_code"]
        trusts.push(trust) unless trusts.index(trust)


        # 建物が定義されていた時
        if rec["building_id"]

          # 建物情報
          building = {}
          building[:id] = rec["building_id"]
          building[:name] = rec["building_name"]
          building[:address] = rec["building_address"]
          building[:latitude] = rec["building_latitude"]
          building[:longitude] = rec["building_longitude"]
          buildings.push(building) unless buildings.index(building)

          # 営業所情報
          shop = {}
          shop[:id] = rec["shop_id"]
          shop[:name] = rec["shop_name"]
          shop[:icon] = rec["shop_icon"]
          shop[:latitude] = rec["shop_latitude"]
          shop[:longitude] = rec["shop_longitude"]
          shops.push(shop) unless shops.index(shop)

          # 貸主に紐づく建物一覧を作成する。
          owner_to_buildings[owner[:id]] = [] unless owner_to_buildings[owner[:id]]
          owner_to_buildings[owner[:id]] << building

          # 建物に紐づく貸主一覧を作成する。※本来建物に対するオーナーは１人だが、念のため複数オーナーも対応する。
          building_to_owners[building[:id]] = [] unless building_to_owners[building[:id]]
          building_to_owners[building[:id]] << owner

        end

        # unless tmp_building_id == rec['building_id']
        #
        #   tmp_building_id = rec['building_id']
        #   building_id_arr.push(rec['building_id'])
        #
        # end
      end

      # buildings = Building.find_all_by_id(building_id_arr)
      # buildings = [] unless buildings
      #
      # # 絞りこまれた建物を元に、貸主・委託・営業所を取得する
      # buildings_to_gon(buildings)

      gon.trust_manages = trust_manages
      gon.buildings = buildings
      gon.owners = owners
      gon.trusts = trusts
      gon.shops = shops
      gon.owner_to_buildings = owner_to_buildings
      gon.building_to_owners = building_to_owners
      gon.manage_line_color  make_manage_line_list
      gon.all_shops = Shop.find(:all)


      # ランク見込みオプション
      @rank_searchoptions = ""
      AttackState.all.each do |rank|
        @rank_searchoptions = @rank_searchoptions + ";" + rank.code + ":" + rank.name
      end

      render "owner_building_list"

    else
      # 不正な検索条件が指定されたとき
      render "owner_building_list"
    end
  end

  # タックシールを出力する
  def tack_out
    @selected = params[:dm_owner_list]

    if params[:dm_history] == "1"
      reg_flg = true
    else
      reg_flg = false
    end

    # owner_id_arr = []
    #
    # Owner.where("id in (" + @selected + ")" ).each do |owner|
    #   owner_id_arr.push(owner.id) if owner.dm_delivery
    # end
    #
    # # 出力対象が１つもないときはエラー
    # if owner_id_arr.length == 0
    #   flash[:notice] = '印刷対象のチェックボックスをチェックしてください。'
    #   redirect_to :action => "index"


    msg = ""
    rank_arr = []
    ptn_str = ""

    ####################
    # ランクのチェック
    ####################
    rank_arr.push("S") if params[:rank_s]
    rank_arr.push("A") if params[:rank_a]
    rank_arr.push("B") if params[:rank_b]
    rank_arr.push("C") if params[:rank_c]
    rank_arr.push("D") if params[:rank_d]

    if rank_arr.length == 0
      msg = msg + "出力対象の見込みランクが未指定です。　　　"
    end

    ####################
    # パターンのチェック
    ####################
    if params[:ptn_1]
      ptn_str = ptn_str + " dm_ptn_1 = 1" # SQLServerは1
    end

    if params[:ptn_2]
      unless ptn_str == ""
        ptn_str = ptn_str + " Or "
      end

      ptn_str = ptn_str + " dm_ptn_2 = 1" # SQLServerは2
    end

    if params[:ptn_3]
      unless ptn_str == ""
        ptn_str = ptn_str + " Or "
      end

      ptn_str = ptn_str + " dm_ptn_3 = 1" # SQLServerは2
    end

    if params[:ptn_4]
      unless ptn_str == ""
        ptn_str = ptn_str + " Or "
      end

      ptn_str = ptn_str + " dm_ptn_4 = 1 " # SQLServerは2
    end

    if params[:ptn_5]
      unless ptn_str == ""
        ptn_str = ptn_str + " Or "
      end

      ptn_str = ptn_str + " dm_ptn_5 = 1 " # SQLServerは2
    end

    if params[:ptn_6]
      unless ptn_str == ""
        ptn_str = ptn_str + " Or "
      end

      ptn_str = ptn_str + " dm_ptn_6 = 1 " # SQLServerは2
    end

    if params[:ptn_7]
      unless ptn_str == ""
        ptn_str = ptn_str + " Or "
      end

      ptn_str = ptn_str + " dm_ptn_7 = 1 " # SQLServerは2
    end

    if params[:ptn_8]
      unless ptn_str == ""
        ptn_str = ptn_str + " Or "
      end

      ptn_str = ptn_str + " dm_ptn_8 = 1 " # SQLServerは2
    end

    if ptn_str == ""
      msg = msg + "出力対象のパターンが未指定です。　　　"
    end

    # パラメータが不正の時はエラーメッセージを表示
    unless msg == ""
        flash[:danger] = "DMタックシール出力エラー：" + msg
        redirect_to action: "index"
    else

      rank_tmp = ""
      rank_arr.each do |rank|
        unless rank_tmp == ""
          rank_tmp = rank_tmp + ","
        end

        rank_tmp = rank_tmp + "'" + rank + "'"
      end

      str_sql = ""
      str_sql = str_sql + " SELECT distinct owners.id as owner_id"
      str_sql = str_sql + " FROM owners inner join trusts on owners.id = trusts.owner_id "
      str_sql = str_sql + " inner join attack_states on trusts.attack_state_id = attack_states.id "
      str_sql = str_sql + " where trusts.biru_user_id = " + params[:sid]
      str_sql = str_sql + " and trusts.delete_flg = 0"
      str_sql = str_sql + " and owners.delete_flg = 0"
      str_sql = str_sql + " and owners.dm_delivery = 1 "
      str_sql = str_sql + " and attack_states.code in ( " + rank_tmp + ")  "
      str_sql = str_sql + " and  ( " + ptn_str + ")  "

      owner_id_arr = []
      ActiveRecord::Base.connection.select_all(str_sql).each do |rec|
        owner_id_arr.push(rec["owner_id"])
      end

      @owners = Owner.find_all_by_id(owner_id_arr)

      # pdfファイルを作成
      # report = ThinReports::Report.create :layout => File.join(Rails.root, 'app/reports', 'pdf_layout.tlf') do |r|
      report = ThinReports::Report.create layout: File.join(Rails.root, "app/reports", params[:dm_tack_kind]) do |r|
         @owners.each_with_index do |owner, idx|
           lbl_num = (idx).modulo(21) # 剰余を求める

           if lbl_num == 0
             r.start_new_page
           end

           unless owner.postcode.blank?
             r.page.values "post_%02d"%(lbl_num + 1) => "〒" + owner.postcode
           end

           r.page.values "address_%02d"%(lbl_num + 1) => owner.address
           r.page.values "name_%02d"%(lbl_num + 1) => owner.name + " " + if owner.honorific_title.blank? then "様"  else owner.honorific_title end
           #           r.page.values "biru_%02d"%(lbl_num + 1) => '(株)中央ビル管理 ' + @biru_user.name

           # アプローチデータ登録
           if reg_flg
             owner_approach = OwnerApproach.new
             owner_approach.owner_id = owner.id
             owner_approach.approach_kind_id = ApproachKind.find_by_code("0030").id
             owner_approach.approach_date = params[:dm_out_date]
             owner_approach.content = params[:dm_out_msg]
             owner_approach.biru_user_id = @biru_user.id
             owner_approach.delete_flg = false
             owner_approach.save!
           end
         end
       end

       send_data report.generate, filename: "DM_" +  Date.today.to_s +  ".pdf",
                                  type: "application/pdf",
                                  disposition: "attachment"

    end
  end

  # ファイル出力（CSV出力）
  def csv_out
    str = ""

    params[:data].keys.each do |key|
      str = str + params[:data][key].values.join(",")
      str = str + "\n"
    end

    send_data str, filename: "output.csv"
  end


  # # アタック用の貸主情報登録
  # def attack_owner_new
  #   @attack_owner = Owner.new
  # end
  #
  # # アタック貸主を登録
  # def attack_owner_create
  #   @attack_owner = Owner.new(params[:owner])
  #   @attack_owner.biru_user_id = @biru_user.id
  #
  #   @attack_owner.attack_code = attack_conv_code(@biru_user.id.to_s,  @attack_owner.address,  @attack_owner.name)
  #
  #   # 住所のGEOCODE
  #   gmaps_ret = Gmaps4rails.geocode(@attack_owner.address)
  #   @attack_owner.latitude = gmaps_ret[0][:lat]
  #   @attack_owner.longitude = gmaps_ret[0][:lng]
  #   @attack_owner.gmaps = true
  #   @attack_owner.delete_flg = false
  #
  #   @attack_owner.save!
  #
  #   t = Trust.new
  #   t.owner_id = @attack_owner.id
  #   t.biru_user_id = @biru_user.id
  #   t.save!
  #
  #   redirect_to :action=>'index'
  # end

  # 個人別のユーザーレポートを表示します
  def trust_user_report
    # ランクがB以上のもの
    # DMを送ったもの
    # 訪問をしたもの
    # TELアプローチしたもの

    # 対象の期間を取得
    @month = ""
    if params[:month]
      @month = params[:month]
    else
      # 当月の月を出す。
      @month = get_cur_month
    end

    # 来月度を取得
    tmp_month = Date.parse(@month + "01", "YYYYMMDD").next_month
    @month_next = "%04d%02d"%[ tmp_month.year, tmp_month.month ]

    # 前月度を取得
    tmp_month =Date.parse(@month + "01", "YYYYMMDD").prev_month
    @month_prev = "%04d%02d"%[ tmp_month.year, tmp_month.month ]

    # ユーザー情報取得
    @biru_trust_user = BiruUser.find(params[:sid])

    # 2016.05.05 del
    # この個人レポート画面へのアクセスはログインユーザーと同じか、全員参照権限を持ったユーザーのみ。それ以外はエラーページへリダイレクトする
    # unless TrustManagementsController.check_report_auth(@biru_user, @biru_trust_user)
    #   flash[:notice] = @biru_trust_user.name + 'さんの受託月報ページへアクセスできるのは、ログインユーザー当人か権限をもったユーザーのみです'
    #   redirect_to :controller=>'pages', :action=>'error_page'
    # end

    # レポート情報の取得
    @report = TrustAttackMonthReport.find_or_create_by_month_and_biru_user_id(@month, @biru_trust_user.id)

    # 先月のレポート情報の取得
    @report_prev = TrustAttackMonthReport.find_or_create_by_month_and_biru_user_id(@month_prev, @biru_trust_user.id)

    # 来月の計画・実績データを取得
    @biru_user_monthly_next = BiruUserMonthly.find_by_biru_user_id_and_month(@biru_trust_user.id, @month_next)
    unless @biru_user_monthly_next
      @biru_user_monthly_next = BiruUserMonthly.new
    end
    @biru_user_monthly_next.biru_user_id = @biru_trust_user.id
    @biru_user_monthly_next.month = @month_next

   #     @visit_owner_id_arr = @report.visit_owners_absence
   #     @dm_owner_id_arr = @report.dm_owners_send
   #     @tel_owner_id_arr = @report.tel_owners_call
   #     #@buildings = result[:buildings]
   #
   #     @buildings = []
   #     Trust.where("id in (" + @report.rank_b_trusts + ")").each do |trust|
   #       @buildings << trust.building
   #     end
   #
   #     # 物件情報の取得
   #     gon.visit_owner = Owner.find_all_by_id(@visit_owner_id_arr)
   #     gon.dm_owner = Owner.find_all_by_id(@dm_owner_id_arr)
   #     gon.tel_owner =  Owner.find_all_by_id(@tel_owner_id_arr)
   #
   #     @shops, @owners, @trusts, @owner_to_buildings, @building_to_owners = get_building_info(@buildings)
   #     @manage_line_color = make_manage_line_list
   #
   #     # ランクが設定されている物件を表示
   #     gon.rank_buildings = @buildings
   #     gon.rank_owners = @owners # 関連する貸主
   #     gon.rank_trusts = @trusts # 関連する委託契約
   #     gon.rank_shops = @shops    # 関連する営業所
   #     gon.rank_owner_to_buildings = @owner_to_buildings # 建物と貸主をひもづける情報
   #     gon.rank_building_to_owners = @building_to_owners
   #     gon.rank_manage_line_color = @manage_line_color
   #
   #     gon.all_shops = Shop.find(:all)
   #     @search_type = 1
   #
   #     # 駅の追加
   #     station_arr = []
   #     station_arr.push(["1","15"]) # 草加
   #     station_arr.push(["1","17"]) # 新田
   #     station_arr.push(["1","8" ]) # 北千住
   #     station_arr.push(["1","19"]) # 新越谷
   #     station_arr.push(["2","14"]) # 南越谷
   #     station_arr.push(["1","20"]) # 越谷
   #     station_arr.push(["1","21"]) # 北越谷
   #     station_arr.push(["1","23"]) # せんげん台
   #     station_arr.push(["1","26"]) # 春日部
   #     station_arr.push(["6","6"])  # 戸田公園
   #     station_arr.push(["7","6"])  # 戸田
   #     station_arr.push(["11","5"]) # 与野
   #     station_arr.push(["9","5"])  # 浦和
   #     station_arr.push(["5","5"])  # 川口
   #     station_arr.push(["2","12"]) # 東浦和
   #     station_arr.push(["2","13"]) # 東川口
   #     station_arr.push(["7","3"])  # 松戸
   #     station_arr.push(["8","3"])  # 北松戸
   #     station_arr.push(["2","18"]) # 南流山
   #     station_arr.push(["3","13"]) # 柏
   #
   # stations = []
   # station_arr.each do | station_pair |
   #   station = Station.find_by_line_code_and_code(station_pair[0], station_pair[1])
   #
   #       # if station
   #       #   p "駅あり"
   #       #       else
   #       #   p "駅なし"
   #       # end
   #       #
   #   stations << station if station
   # end
   #
   #    gon.stations = stations

   ######################
   # 行動内訳履歴を表示
   ######################
   grid_data_approach = []
   approach_owners = []
   check_owner = {}

   @report.trust_attack_month_report_actions.order("approach_date desc").each do |action_rec|
     no_dm = true # 2015.07.22 DMだったら地図に出さないようにする。

     case action_rec.approach_kind_code
     when "0010", "0020" # 訪問
       icon = "/biruweb/assets/marker_btn_blue.png"
     when "0030", "0035" # ＤＭ
       icon = "/biruweb/assets/marker_btn_green.png"
       no_dm = false
     when "0040", "0045" # 電話
       icon = "/biruweb/assets/marker_btn_orange.png"
     when "0025" # 提案
       icon = "/biruweb/assets/marker_btn_red.png"
     else
       icon = "/biruweb/assets/marker_gray.png"
     end

     # 地図へ表示するアイコンの情報
     approach_owner = {
         id: action_rec.owner_id, name: action_rec.owner_name, latitude: action_rec.owner_latitude, longitude: action_rec.owner_longitude, icon: icon
     }

     # 2015.07.22 DM以外を地図のアイコン表示
     if no_dm
       unless check_owner[approach_owner[:id]]
         approach_owners.push(approach_owner)
         check_owner[approach_owner[:id]] = true
       end
     end

     # アプローチ種別が面談・電話会話・DM反響・提案の時のみ行動詳細に表示
     case action_rec.approach_kind_code
     when "0020", "0035", "0045", "0025"
       # jqgridに表示する一覧の情報(訪問の面談・提案・TELの応答のみ表示。それ以外は対象外)
       row_data = {}
       row_data[:owner_id] = action_rec.owner_id
       row_data[:approach_kind] = action_rec.approach_kind_name
       row_data[:approach_date] = action_rec.approach_date
       row_data[:approach_content] = action_rec.content
       row_data[:owner_code] = action_rec.owner_code
       row_data[:owner_name] = action_rec.owner_name
       row_data[:owner_address] = action_rec.owner_address

       grid_data_approach.push(row_data)
     end
   end

   gon.grid_data_approach = grid_data_approach
   gon.approach_owners = approach_owners

   # 一覧をしぼったコンボボックスの表示
   result = ":"
   ApproachKind.where("code in ('0020', '0035', '0045', '0025')").order(:sequence).each do |obj|
     result = result + ";" + obj.name + ":" + obj.name
   end
   result

   @combo_approach_kinds = result



   ######################
   # ランクデータを表示
   ######################
   grid_data_rank = []
   rank_buildings = []
   check_building = {}

   @trust_expect_buildings = [] # 2018.02.10 add ランクA or Sの物件
   @trust_expect_buildings_b = [] # 2018.04.22 add ランクB or Cの物件

   @report.trust_attack_month_report_ranks.each do |rank_rec|
     unless rank_rec.attack_state_this_month
        p "trust_attack_month_report_ranks: " + rank_rec.id.to_s
        next
     end

     case rank_rec.attack_state_this_month.code
     when "S"
       icon = "/biruweb/assets/marker_orange.png"
       @trust_expect_buildings.push(rank_rec)
     when "A"
       icon = "/biruweb/assets/marker_green.png"
       @trust_expect_buildings.push(rank_rec)
     when "B"
       icon = "/biruweb/assets/marker_purple.png"
       @trust_expect_buildings_b.push(rank_rec)
     when "C"
       icon = "/biruweb/assets/marker_red.png"
     when "Z"
       icon = "/biruweb/assets/marker_white.png"
     else
       icon = "/biruweb/assets/marker_gray.png"
     end

     # 地図へ表示するアイコンの情報
     rank_building = {
         id: rank_rec.building_id, name: rank_rec.building_name, latitude: rank_rec.building_latitude, longitude: rank_rec.building_longitude, icon: icon, owner_id: rank_rec.owner_id
     }

     unless check_building[rank_building[:id]]
       rank_buildings.push(rank_building)
       check_building[rank_building[:id]] = true
     end


     row_data = {}
     row_data[:attack_state_last_month] = rank_rec.attack_state_last_month.code
     row_data[:attack_state_this_month] = rank_rec.attack_state_this_month.code

     case rank_rec.change_status
     when 0
       row_data[:change_status] = "変更なし"
     when 1
       row_data[:change_status] = "ランクダウン"
     when 2
       row_data[:change_status] = "ランクアップ"
     else
       row_data[:change_status] = "不明"
     end

     row_data[:change_month] = rank_rec.change_month
     row_data[:building_id] = rank_rec.building_id
     row_data[:building_name] = rank_rec.building_name
     row_data[:owner_id] = rank_rec.owner_id

     row_data[:room_num] = rank_rec.room_num
     row_data[:approach_cnt] = rank_rec.approach_cnt

     row_data[:selective_type] = ""
     row_data[:build_type]  = ""

     biru = Building.find(rank_rec.building_id)
     if biru
       row_data[:selective_type] = biru.selective_disp

       if biru.build_type_id
         row_data[:build_type] = biru.build_type.name
       end

     end

     grid_data_rank.push(row_data)
   end
   gon.grid_data_rank = grid_data_rank
   gon.rank_buildings = rank_buildings


   @combo_rank = jqgrid_combo_rank
   @data_update = TrustAttackMonthReportUpdateHistory.find_by_month(@month)

   ###################
   # レポートデータ取得
   ###################
   date_hash = { "21"=>[ 0, 0, 0, 0, 0 ], "22"=>[ 0, 0, 0, 0, 0 ], "23"=>[ 0, 0, 0, 0, 0 ], "24"=>[ 0, 0, 0, 0, 0 ], "25"=>[ 0, 0, 0, 0, 0 ], "26"=>[ 0, 0, 0, 0, 0 ], "27"=>[ 0, 0, 0, 0, 0 ], "28"=>[ 0, 0, 0, 0, 0 ], "29"=>[ 0, 0, 0, 0, 0 ], "30"=>[ 0, 0, 0, 0, 0 ], "31"=>[ 0, 0, 0, 0, 0 ], "01"=>[ 0, 0, 0, 0, 0 ], "02"=>[ 0, 0, 0, 0, 0 ], "03"=>[ 0, 0, 0, 0, 0 ], "04"=>[ 0, 0, 0, 0, 0 ], "05"=>[ 0, 0, 0, 0, 0 ], "06"=>[ 0, 0, 0, 0, 0 ], "07"=>[ 0, 0, 0, 0, 0 ], "08"=>[ 0, 0, 0, 0, 0 ], "09"=>[ 0, 0, 0, 0, 0 ], "10"=>[ 0, 0, 0, 0, 0 ], "11"=>[ 0, 0, 0, 0, 0 ], "12"=>[ 0, 0, 0, 0, 0 ], "13"=>[ 0, 0, 0, 0, 0 ], "14"=>[ 0, 0, 0, 0, 0 ], "15"=>[ 0, 0, 0, 0, 0 ], "16"=>[ 0, 0, 0, 0, 0 ], "17"=>[ 0, 0, 0, 0, 0 ], "18"=>[ 0, 0, 0, 0, 0 ], "19"=>[ 0, 0, 0, 0, 0 ], "20"=>[ 0, 0, 0, 0, 0 ] }


   str_sql = ""
   str_sql = str_sql + " select approach_kind_code, biru.F_UTIL_DATE_FORMAT(b.approach_date, '%d') as key_date, count(*) as cnt" # todo sqlserver
   str_sql = str_sql + " from trust_attack_month_reports a"
   str_sql = str_sql + " inner join trust_attack_month_report_actions b on a.id = b.trust_attack_month_report_id"
   str_sql = str_sql + " where a.month = '" + @month + "'"
   str_sql = str_sql + " and a.biru_user_id = '" + @biru_trust_user.id.to_s + "'"
   str_sql = str_sql + " and b.delete_flg = 0 "  # todo sqlserver
   str_sql = str_sql + " group by approach_kind_code, b.approach_date"

   ActiveRecord::Base.connection.select_all(str_sql).each do |rec|
     case rec["approach_kind_code"]
     when "0010" then # 訪問(留守)
       date_hash[rec["key_date"]][0] += rec["cnt"]
     when "0020" then # 訪問(面談)
       date_hash[rec["key_date"]][0] += rec["cnt"]
       date_hash[rec["key_date"]][1] += rec["cnt"]
     when "0025" then # 訪問(提案)
       date_hash[rec["key_date"]][0] += rec["cnt"]
       date_hash[rec["key_date"]][1] += rec["cnt"]
       date_hash[rec["key_date"]][2] += rec["cnt"]
     when "0040" then # 電話(留守)
       date_hash[rec["key_date"]][3] += rec["cnt"]
     when "0045" then # 電話(会話)
       date_hash[rec["key_date"]][3] += rec["cnt"]
       date_hash[rec["key_date"]][4] += rec["cnt"]
     end
   end


   #----------------------------------
   # 棒グラフ作成（訪問)
   #----------------------------------
   @graph_visit_detail = LazyHighCharts::HighChart.new("graph_visit_detail") do |f|
     f.title(text: "訪問")
     f.xAxis(categories: date_hash.keys, tickInterval: 1) # 1とかは列の間隔の指定

     # 凡例
     f.legend(
         layout: "vertical",
         reversed: false,
         backgroundColor: "#FFFFFF",
         floating: true,
         align: "right",
         x: 0,
         y: 50,
         verticalAlign: "top"
     )

     f.series(name: "訪問", data: date_hash.keys.map do |key| date_hash[key][0] end, type: "column", color: "#3276b1")
     f.series(name: "面談", data: date_hash.keys.map do |key| date_hash[key][1] end, type: "column", color: "#d9534f")
     # f.series(name: '提案', data: date_hash.keys.map do |key| date_hash[key][2] end, type: "column", color: '#8cc63f')
   end

   #----------------------------------
   # 棒グラフ作成（電話)
   #----------------------------------
   @graph_tel_detail = LazyHighCharts::HighChart.new("graph_tel_detail") do |f|
     f.title(text: "TELアプローチ")
     f.xAxis(categories: date_hash.keys, tickInterval: 1) # 1とかは列の間隔の指定

     # 凡例
     f.legend(
         layout: "vertical",
         reversed: false,
         backgroundColor: "#FFFFFF",
         floating: true,
         align: "right",
         x: 0,
         y: 50,
         verticalAlign: "top"
     )

     f.series(name: "電話", data: date_hash.keys.map do |key| date_hash[key][3] end, type: "column", color: "#3276b1")
     f.series(name: "会話", data: date_hash.keys.map do |key| date_hash[key][4] end, type: "column", color: "#d9534f")
   end


   #----------------------------------
   # 円グラフ作成（ランク）
   #----------------------------------
   @graph_pie_rank = LazyHighCharts::HighChart.new("graph_pie_rank") do |f|
     f.chart({ defaultSeriesType: "pie", margin: [ 0, 0, 0, 0 ] })

     f.series({
       type: "pie",
       name: "見込みランク",
       data: [
         [ "Sランク", @report.rank_s ],
         [ "Aランク", @report.rank_a ],
         [ "Bランク", @report.rank_b ],
         [ "Cランク", @report.rank_c ]
       ]
     })
   end



   # layoutでヘッダを非表示
   @header_hidden = true
  end

  def biru_user_trust_update
    if params[:biru_user_monthly][:id] == ""
      @biru_user_monthly = BiruUserMonthly.new
    else
      @biru_user_monthly = BiruUserMonthly.find(params[:biru_user_monthly][:id])
    end

    @biru_user_monthly.update_attributes(params[:biru_user_monthly])

    # 戻る月は前月なので、１ヶ月戻す
    prev_month = Date.parse(@biru_user_monthly.month + "01", "YYYYMMDD").prev_month.strftime("%Y%m")
    redirect_to action: "trust_user_report", sid: @biru_user_monthly.biru_user_id, month: prev_month
  end


  # 管理受託月報の担当者コメントを登録
  def trust_user_report_user_comments
    @report = TrustAttackMonthReport.find(params[:trust_attack_month_report][:id])
    @report.comment_user_could = params[:trust_attack_month_report][:comment_user_could]
    @report.comment_user_not_could = params[:trust_attack_month_report][:comment_user_not_could]
    @report.comment_user_plan = params[:trust_attack_month_report][:comment_user_plan]
    @report.comment_user_updated_user = @biru_user
    @report.comment_user_updated_at = DateTime.now
    @report.save
    redirect_to action: "trust_user_report", sid: @report.biru_user_id, month: @report.month
  end

  # 管理受託月報の上司コメントを登録
  def trust_user_report_boss_comments
    @report = TrustAttackMonthReport.find(params[:trust_attack_month_report][:id])
    @report.comment_boss_could = params[:trust_attack_month_report][:comment_boss_could]
    @report.comment_boss_not_could = params[:trust_attack_month_report][:comment_boss_not_could]
    @report.comment_boss_plan = params[:trust_attack_month_report][:comment_boss_plan]
    @report.comment_boss_updated_user = @biru_user
    @report.comment_boss_updated_at = DateTime.now
    @report.save
    redirect_to action: "trust_user_report", sid: @report.biru_user_id, month: @report.month
  end

  def trust_user_report_apply_comment_update
    trust_attack_month_report_result = TrustAttackMonthReportResult.unscoped.find_or_create_by_id(params[:trust][:id])
    trust_attack_month_report_result.comment = params[:trust][:comment]
    trust_attack_month_report_result.comment_updated_at = DateTime.now()
    trust_attack_month_report_result.comment_updated_user = @biru_user.id
    trust_attack_month_report_result.save

    report = trust_attack_month_report_result.trust_attack_month_report
    redirect_to action: "trust_user_report", sid: report.biru_user_id, month: report.month
  end


  def owner_show
    get_owner_show(params[:id].to_i)
  end

  def owner_update
     @owner = Owner.find(params[:id])
     if @owner.update_attributes(params[:owner])

       redirect_to controller: "trust_managements", action: "owner_show"

       # format.html { redirect_to 'index', notice: 'Book was successfully updated.' }
       # format.json { render :show, status: :ok, location: @owner }
     else

       redirect_to controller: "trust_managements", action: "owner_show"

       # format.html { render :owner_show }
       # format.json { render json: @book.errors, status: :unprocessable_entity }
     end
  end

  def building_show
    @building = Building.find(params[:id].to_i)
  end

  def building_update
    @building = Building.find(params[:id].to_i)
    if @building.update_attributes(params[:building])
      redirect_to controller: "trust_managements", action: "building_show"
    else
      redirect_to controller: "trust_managements", action: "building_show"
    end
  end

  # アプローチ履歴を登録する
  def owner_approach_regist
    @owner_approach = OwnerApproach.new(params[:owner_approach])

    respond_to do |format|
      if @owner_approach.save
        format.html { redirect_to controller: "trust_managements", action: "owner_show", id: params[:owner_approach][:owner_id].to_i, notice: "Book was successfully created." }
        format.json { render json: @owner_approach, status: :created, location: @owner_approach }
      else
        get_owner_show(params[:owner_approach][:owner_id].to_i)
        format.html { render action: "owner_show" }
        format.json { render json: @owner_approach.errors, status: :unprocessable_entity }
      end
    end
  end

  # アタックリストメンテナンス
  def attack_list_maintenance
    @biru_trust_user = BiruUser.find(params[:sid])

    # 貸主の一覧を取得
    gon.buildings = ActiveRecord::Base.connection.select_all(get_buildings_sql(@biru_trust_user))

    # 建物の一覧を取得
    gon.owners = ActiveRecord::Base.connection.select_all(get_owners_sql(@biru_trust_user, false))

    # 委託契約の一覧を取得
    gon.trusts = ActiveRecord::Base.connection.select_all(get_trust_sql(@biru_trust_user, "", true))

    # layoutでヘッダを非表示
    @header_hidden = true
  end

  # アタックリスト一括メンテナンス
  def attack_list_maintenance_bulk
    @biru_trust_user = BiruUser.find(params[:sid])
    @header_hidden = true # ヘッダを非表示にする
  end

  # アタックリスト一括メンテナンス　貸主出力
  def attack_list_maintenance_bulk_owner_csv
    @biru_trust_user = BiruUser.find(params[:sid])
    @header_hidden = true # ヘッダを非表示にする
    data = ActiveRecord::Base.connection.select_all(get_owners_sql(@biru_trust_user, true))

    #-------------
    # CSV出力
    #-------------
    output_path = Rails.root.join("tmp", "owner_list_.csv")

    header = [ "attack_code", "dm", "name", "honorific_title", "kana", "postcode", "address", "tel", "memo", "dm_1", "dm_2", "dm_3", "dm_4", "dm_5", "dm_6", "news_letter_1", "news_letter_2", "rank_s", "rank_a", "rank_b", "rank_c", "rank_d", "rank_z", "rank_x", "rank_y", "rank_w" ]
    csv_data = CSV.generate("", headers: header, write_headers: true) do |csv|
      data.each do |line|
        csv << line
      end
    end

    # 文字コード変換
    send_data csv_data, filename: "owner_list.csv"
  end

  # アタックリスト一括メンテナンス　取込み
  def attack_list_maintenance_bulk_owner_input
    @biru_trust_user = BiruUser.find(params[:sid])
    @header_hidden = true # ヘッダを非表示にする

    app_con = ApplicationController.new
    begin
      csv_text = params[:upload_file].read
    rescue
      # リダイレクト
      flash[:danger] = "正しいファイルを設定してください"
      redirect_to action: "popup_owner_create", sid: params[:sid]
      return
      # render 'attack_list_maintenance_bulk'

    end

    owner_list = []

    # 文字列をUTF-8に変換
    cnt = 0
    CSV.parse(Kconv.toutf8(csv_text)) do |row|
      if cnt == 0
        #---------------------------------------
        # 1行目の時はフォーマットチェック
        #---------------------------------------
        res, msg = format_check_owner(row)
        unless res
          flash[:danger] = msg
          break
        end
      else
        #---------------------------------------
        # 2行目以降であればデータ登録
        #---------------------------------------

        # ハッシュを生成
        unless row[2]
          flash[:danger] =  "登録エラー  " + cnt.to_s + "件目の　貸主名が空白になっています。" + row[0].to_s + " " + row[1].to_s + " " + row[3].to_s + " "
          break
        end

        name = Moji.han_to_zen(row[2].strip)
        address = Moji.han_to_zen((row[6].strip).tr("０-９", "0-9").gsub("－", "-"))

        hash = app_con.conv_code_owner(@biru_trust_user.id.to_s, address, name)
        dm = row[1]
        honorific_title = row[3]
        kana = row[4]
        postcode = row[5]
        tel = row[7]
        memo = row[8]
        ptn1 = row[9].strip if row[9]
        ptn2 = row[10].strip if row[10]
        ptn3 = row[11].strip if row[11]
        ptn4 = row[12].strip if row[12]
        ptn5 = row[13].strip if row[13]
        ptn6 = row[14].strip if row[14]
        ptn7 = row[15].strip if row[15]
        ptn8 = row[16].strip if row[16]

        # もしアタックコードがあれば、そこから現状のデータを取得
        if row[0] != nil  && row[0].length > 0
          id = row[0][2, 10].to_i
          # owner = Owner.where("biru_user_id = " + @biru_trust_user.id.to_s ).where("id = " + id.to_s).first
          owner = Owner.where("id = " + id.to_s).first
          unless owner
            # もしアタックコードが指定されていながらそのコードが存在しなければエラー
            flash[:danger] =  "登録エラー  " + cnt.to_s + "件目の　アタックCD:" + row[0] + "は存在しません" + "(" + id.to_s + ")"
            break
          end

        else

          begin

            # なければハッシュ（＝同一貸主名&住所）から検索　それでもなければ新規作成
            owner = Owner.unscoped.find_or_create_by_hash_key(hash)

            # biru_geocodeで失敗するとdelete_flgが立ってしまうが、
            # 今回はそれを無視したいので、変更前のものを退避 2016/06/19
            before_delete_flg = owner.delete_flg

            # IDを発番する為にsaveするが、その為にはgeocodeしている必要があるのでここで実施
            owner.address = address
            biru_geocode(owner, true)

            # 2016/06/19 add
            owner.delete_flg = before_delete_flg

            owner.save!
            owner.attack_code = "OA%06d"%owner.id # 貸主idをattack_codeとする
            owner.save!

          rescue
            flash[:danger] =  "登録エラー  " + cnt.to_s + "件目の　貸主名:" + owner.name + "の保存に失敗しました。住所などが正しいか確認してください。"
            break
          end

        end

        owner.hash_key = hash
        owner.name = name
        owner.kana = kana
        owner.honorific_title = honorific_title
        owner.tel = tel
        owner.biru_user_id = @biru_trust_user.id.to_s

        if dm == "○" || dm == "〇" then owner.dm_delivery = true else owner.dm_delivery = false end

        if ptn1 == "○" || ptn1 == "〇" then owner.dm_ptn_1 = true else owner.dm_ptn_1 = false end
        if ptn2 == "○" || ptn2 == "〇" then owner.dm_ptn_2 = true else owner.dm_ptn_2 = false end
        if ptn3 == "○" || ptn3 == "〇" then owner.dm_ptn_3 = true else owner.dm_ptn_3 = false end
        if ptn4 == "○" || ptn4 == "〇" then owner.dm_ptn_4 = true else owner.dm_ptn_4 = false end

        if ptn5 == "○" || ptn5 == "〇" then owner.dm_ptn_5 = true else owner.dm_ptn_5 = false end
        if ptn6 == "○" || ptn6 == "〇" then owner.dm_ptn_6 = true else owner.dm_ptn_6 = false end
        if ptn7 == "○" || ptn7 == "〇" then owner.dm_ptn_7 = true else owner.dm_ptn_7 = false end
        if ptn8 == "○" || ptn8 == "〇" then owner.dm_ptn_8 = true else owner.dm_ptn_8 = false end

        owner.memo = memo
        owner.postcode = postcode
        if owner.address != address
          # 住所が違っていた時のみgeocodeもかける

          owner.address = address

          # biru_geocodeで失敗するとdelete_flgが立ってしまうが、
          # 今回はそれを無視したいので、変更前のものを退避 2016/06/19
          before_delete_flg = owner.delete_flg

          # geocode
          biru_geocode(owner, true)

          # 2016/06/19 add
          owner.delete_flg = before_delete_flg

        end

        begin
          # owner.save(:validate => false)
          owner_list.push(owner)
       rescue => e
          # もしアタックコードが指定されていながらそのコードが存在しなければエラー
          # flash[:danger] = cnt.to_s + '行目　貸主ID:' + owner.id.to_s + ' 貸主名:' + owner.name + ' 住所:' + owner.address + ' ' + e.to_s
          break
        end

      end

      cnt = cnt + 1
    end

    unless flash[:danger]

      # ここでエラーチェックが通ったものをまとめて保存処理
      begin
        owner_list.each do |owner|
          owner.save(validate: false)
        end
      rescue => e
        # 保存時のエラー
        flash[:danger] = e.message
      end

      unless flash[:danger]
        # エラーが発生していない時は登録メッセージを設定
        flash[:notice] = (cnt-1).to_s + "件が処理されました。"
      end

    end

    # render 'attack_list_maintenance_bulk'
    render "popup_owner_create"
  end

  # owner一括取り込み　フォーマットチェック
  def format_check_owner(row)
    return false, "1列目が「attack_code」ではありません。" unless row[0] == "attack_code"
    return false, "2列目が「dm」ではありません。" unless row[1] == "dm"
    return false, "3列目が「name」ではありません。" unless row[2] == "name"
    return false, "4列目が「honorific_title」ではありません。" unless row[3] == "honorific_title"
    return false, "5列目が「kana」ではありません。" unless row[4] == "kana"
    return false, "6列目が「postcode」ではありません。" unless row[5] == "postcode"
    return false, "7列目が「address」ではありません。" unless row[6] == "address"
    return false, "8列目が「tel」ではありません。" unless row[7] == "tel"
    return false, "9列目が「memo」ではありません。" unless row[8] == "memo"

    return true, ""
  end

  def attack_list_add
    # 指定された貸主CD、建物CD
    building_ids = params[:building_ids]
    owner_id = params[:owner_id]
    biru_user_id = params[:sid]

    reg_building_name = []

    # 選択された建物に対して委託の紐付けを行う。
    building_ids.split(",").each do |building_id|
      trust = Trust.unscoped.find_by_owner_id_and_building_id_and_biru_user_id(building_id, owner_id, biru_user_id)
      if trust
        trust.delete_flg = false
        reg_building_name.push(Building.find(building_id).name)
      else
        trust = Trust.new
        trust.building_id = building_id
        trust.owner_id = owner_id
        trust.delete_flg = false

        trust.biru_user_id = biru_user_id
        trust.manage_type_id = ManageType.find_by_code("99").id # 管理外

        reg_building_name.push(Building.find(building_id).name)
      end

      flash[:notice] = "貸主：" + Owner.find(owner_id).name + "  　建物："
      reg_building_name.each do |building_nm|
        flash[:notice] = flash[:notice] + "【" + building_nm + "】、"
      end
      flash[:notice] = flash[:notice] + "　を【Dランク】で追加しました。"

      trust.save!


      # Dランクで履歴に登録
      pri_trust_attack_update(trust.id, get_cur_month, AttackState.find_by_code("X").id, AttackState.find_by_code("D").id, 0, nil, nil)
    end

    redirect_to action: "attack_list_maintenance", sid: params[:sid]
  end


  # 委託契約の紐付けを行います。
  def create_trust
    # 指定された貸主CD、建物CD
    building_id = params[:building_id]
    owner_id = params[:owner_id]
    biru_user_id = params[:biru_user_id]

    reg_building_name = []

    # 選択された建物に対して委託の紐付けを行う。

    trust = Trust.unscoped.find_by_owner_id_and_building_id_and_biru_user_id(building_id, owner_id, biru_user_id)
    if trust
      trust.delete_flg = false
      reg_building_name.push(Building.find(building_id).name)
    else
      trust = Trust.new
      trust.building_id = building_id
      trust.owner_id = owner_id
      trust.delete_flg = false

      trust.biru_user_id = biru_user_id
      trust.manage_type_id = ManageType.find_by_code("99").id # 管理外

      reg_building_name.push(Building.find(building_id).name)
    end

    flash[:notice] = "貸主：" + Owner.find(owner_id).name + "  　建物："
    reg_building_name.each do |building_nm|
      flash[:notice] = flash[:notice] + "【" + building_nm + "】"
    end
    flash[:notice] = flash[:notice] + "　を【Dランク】で追加しました。"
    trust.save!

    # Dランクで履歴に登録
    pri_trust_attack_update(trust.id, get_cur_month, AttackState.find_by_code("X").id, AttackState.find_by_code("D").id, 0, nil, nil)

    redirect_to action: "popup_owner_buildings", owner_id: owner_id, market_radio: "off"
  end

  # 紐付けの解除を行います。
  def delete_trust
    trust = Trust.find(params[:trust_id])
    flash[:notice] = "貸主：" + trust.owner.name + " から " +  trust.building.name + " を削除しました。"

    trust.delete_flg = true
    trust.save!

    redirect_to action: "popup_owner_buildings", owner_id: trust.owner.id, market_radio: "off"
  end


  # 貸主登録
  def owner_regist
    @owner = Owner.new(params[:owner])
    begin

      # gmaps_ret = Gmaps4rails.geocode(@owner.address)
      # @owner.latitude = gmaps_ret[0][:lat]
      # @owner.longitude = gmaps_ret[0][:lng]
      # @owner.gmaps = true
      #

      @owner.name = Moji.han_to_zen(@owner.name)
      @owner.address = Moji.han_to_zen(@owner.address)

      hash = conv_code_owner(params[:owner][:biru_user_id],  @owner.address, @owner.name)
      if Owner.find_by_hash_key(hash)
        raise "この名前・住所は貸主一覧にすでに存在します。"
      end

      @owner.hash_key = hash
      @owner.save!
      @owner.attack_code = "OA%06d"%@owner.id
      @owner.dm_ptn_1 = true
      @owner.save!

      flash[:notice] = "貸主：" + params[:owner][:name] + "  を貸主一覧に追加しました。"
    rescue => e
      flash[:danger] = e.to_s
      # flash[:danger] = "貸主の登録に失敗しました。存在する住所なのかを確認してください。"

    end
    # redirect_to :action => 'attack_list_maintenance', :sid=> params[:owner][:biru_user_id]
    #     redirect_to :action => "popup_owner_create?owner_name=#{params[:owner][:owner_name]}&owner_address=#{params[:owner][:owner_address] }"

    redirect_to action: "popup_owner_create", owner_name: @owner.name, owner_address: @owner.address
  end


  # 建物登録
  def building_regist
    @building = Building.new(params[:building])
    begin

      @building.name = Moji.han_to_zen(@building.name)
      @building.address = Moji.han_to_zen(@building.address)

      hash = conv_code_building(params[:building][:biru_user_id],  @building.address, @building.name)
      if Building.find_by_hash_key(hash)
        raise "この名前・住所は建物一覧にすでに存在します。"
      end

      # 重点地域の判定
      @building.parse_postcode

      @building.hash_key = hash
      @building.save!
      @building.attack_code = "OA%06d"%@building.id
      @building.save!

      flash[:notice] = "建物：" + params[:building][:name] + "  を建物一覧に追加しました。"
    rescue => e
      flash[:danger] = e.to_s
    end
    # redirect_to :action => 'attack_list_maintenance', :sid=> params[:building][:biru_user_id]
    redirect_to action: "popup_owner_buildings", building_name: @building.name, owner_id: params[:owner_id], market_radio: "off"
  end


  # DMの履歴登録などを行います。
  def dm_index
    @user_list = []

    # 当月のTrustAttackMonthReportの一覧を取得
    @month = get_cur_month

    # 指定担当者のアタックリストを取得
    sql = ""
    sql = sql + "SELECT "
    sql = sql + "  A.area_name  "
    sql = sql + "	,A.biru_user_id "
    sql = sql + "	,A.biru_user_name"
    sql = sql + "	,SUM(CASE WHEN B.dm_ptn_1 = 1 THEN 1 ELSE 0 END) AS dm01 "
    sql = sql + "	,SUM(CASE WHEN B.dm_ptn_2 = 1 THEN 1 ELSE 0 END) AS dm02 "
    sql = sql + "	,SUM(CASE WHEN B.dm_ptn_3 = 1 THEN 1 ELSE 0 END) AS dm03 "
    sql = sql + "	,SUM(CASE WHEN B.dm_ptn_4 = 1 THEN 1 ELSE 0 END) AS dm04 "
    sql = sql + "	,SUM(CASE WHEN B.dm_ptn_5 = 1 THEN 1 ELSE 0 END) AS dm05 "
    sql = sql + "	,SUM(CASE WHEN B.dm_ptn_6 = 1 THEN 1 ELSE 0 END) AS dm06 "
    sql = sql + "	,SUM(CASE WHEN B.dm_ptn_7 = 1 THEN 1 ELSE 0 END) AS dm07 "
    sql = sql + "	,SUM(CASE WHEN B.dm_ptn_8 = 1 THEN 1 ELSE 0 END) AS dm08 "
    sql = sql + "FROM ( "
    sql = sql + "SELECT "
    sql = sql + " tr.biru_user_id "
    sql = sql + ",rp.area_name "
    sql = sql + ",usr.name as biru_user_name "
    sql = sql + ",ow.id AS owner_id "
    sql = sql + "FROM trusts tr INNER JOIN owners ow ON tr.owner_id = ow.id "
    sql = sql + "INNER JOIN biru_users usr ON tr.biru_user_id = usr.id "
    sql = sql + "INNER JOIN trust_attack_month_reports rp ON tr.biru_user_id = rp.biru_user_id "
    sql = sql + "WHERE rp.month = '" + @month + "' "
    sql = sql + "  AND tr.delete_flg = 0 "
    sql = sql + "  AND ow.delete_flg = 0 "
    sql = sql + "  AND ow.dm_delivery = 1 "
    sql = sql + "  AND tr.attack_state_id IN ( 1,2,3,4,5 ) " # 見込みランクはS A B C Dのみ
    sql = sql + "GROUP BY  "
    sql = sql + "   ow.id "
    sql = sql + "  ,tr.biru_user_id "
    sql = sql + "  ,usr.name "
    sql = sql + "  ,rp.area_name "
    sql = sql + ") A "
    sql = sql + "INNER JOIN owners B ON A.owner_id = B.id "
    sql = sql + "GROUP BY "
    sql = sql + " A.area_name "
    sql = sql + ",A.biru_user_id "
    sql = sql + ",A.biru_user_name "
    sql = sql + "ORDER BY A.area_name  "

    ActiveRecord::Base.connection.select_all(sql).each do |tmp|
      rec = {}
      rec["area_name"] = tmp["area_name"]
      rec["biru_user_id"] = tmp["biru_user_id"]
      rec["biru_user_name"] = tmp["biru_user_name"]
      rec["dm01"] = tmp["dm01"]
      rec["dm02"] = tmp["dm02"]
      rec["dm03"] = tmp["dm03"]
      rec["dm04"] = tmp["dm04"]
      rec["dm05"] = tmp["dm05"]
      rec["dm06"] = tmp["dm06"]
      rec["dm07"] = tmp["dm07"]
      rec["dm08"] = tmp["dm08"]
      @user_list.push(rec)
    end

    gon.data_list = @user_list
  end

  # DM出力
  def dm_out
    user = BiruUser.find(params[:biru_user_id])

    case  params[:dm_ptn]
    when "1"
        str_where = " AND ow.dm_ptn_1 = 1 "
    when "2"
        str_where = " AND ow.dm_ptn_2 = 1 "
    when "3"
        str_where = " AND ow.dm_ptn_3 = 1 "
    when "4"
        str_where = " AND ow.dm_ptn_4 = 1 "
    when "5"
        str_where = " AND ow.dm_ptn_5 = 1 "
    when "6"
        str_where = " AND ow.dm_ptn_6 = 1 "
    when "7"
        str_where = " AND ow.dm_ptn_7 = 1 "
    when "8"
        str_where = " AND ow.dm_ptn_8 = 1 "
    else
        str_where = " AND 1 = 2" # 予防
    end

    sql = ""
    sql = sql + "SELECT "
    sql = sql + "	 ow.id as owner_id "
    sql = sql + "FROM trusts tr INNER JOIN owners ow ON tr.owner_id = ow.id "
    sql = sql + "INNER JOIN biru_users usr ON tr.biru_user_id = usr.id "
    sql = sql + "WHERE tr.biru_user_id = " + user.id.to_s + " "
    sql = sql + "  AND tr.delete_flg = 0 "
    sql = sql + "  AND ow.delete_flg = 0 "
    sql = sql + "  AND ow.dm_delivery = 1 "
    sql = sql + "  AND tr.attack_state_id IN ( 1,2,3,4,5 ) " # 見込みランクはS A B C Dのみ
    sql = sql + str_where
    sql = sql + "GROUP BY ow.id "


    ActiveRecord::Base.connection.select_all(sql).each do |tmp|
      owner_approach = OwnerApproach.new
      owner_approach.owner_id = tmp["owner_id"]
      owner_approach.approach_kind_id = ApproachKind.find_by_code("0030").id
      owner_approach.approach_date = params[:dm_out_date]
      owner_approach.content = params[:dm_out_msg]
      owner_approach.biru_user_id = user.id
      owner_approach.delete_flg = false
      owner_approach.save!
    end

    redirect_to action: "dm_index"
  end


private
def get_owner_show(owner_id)
  @owner = Owner.find(owner_id)

  @trust_arr = initialize_grid(Trust.where("owner_id = ?", @owner.id))
  @owner_approaches = initialize_grid(OwnerApproach.joins(:owner).includes(:biru_user, :approach_kind).where(owner_id: @owner))

  # 貸主を取得
  gon.owner = @owner

  # 建物を取得
  building_arr = []

  Trust.where("owner_id = ?", @owner.id).each do |trust|
    building_arr.push(trust.building)
  end

  gon.buildings = building_arr
end

# bulk=> true:個別メンテ画面用, false:一括用
def get_owners_sql(object_user, bulk)
  if bulk

    sql = ""
    sql = sql + "SELECT a.id "
    sql = sql + ", a.attack_code "
    sql = sql + ", case a.dm_delivery  when 1 then '○' when 0 then '×' else '--' end as dm "
    sql = sql + ", a.name "
    sql = sql + ", a.honorific_title "
    sql = sql + ", a.kana "
    sql = sql + ", a.postcode "
    sql = sql + ", a.address "
    sql = sql + ", a.tel "
    sql = sql + ", a.memo "
    sql = sql + ", case a.dm_ptn_1  when 1 then '○' when 0 then '×' else '--' end as dm_1 "
    sql = sql + ", case a.dm_ptn_2  when 1 then '○' when 0 then '×' else '--' end as dm_2 "
    sql = sql + ", case a.dm_ptn_3  when 1 then '○' when 0 then '×' else '--' end as dm_3 "
    sql = sql + ", case a.dm_ptn_4  when 1 then '○' when 0 then '×' else '--' end as dm_4 "
    sql = sql + ", case a.dm_ptn_5  when 1 then '○' when 0 then '×' else '--' end as dm_5 "
    sql = sql + ", case a.dm_ptn_6  when 1 then '○' when 0 then '×' else '--' end as dm_6 "
    sql = sql + ", case a.dm_ptn_7  when 1 then '○' when 0 then '×' else '--' end as news_letter_1 "
    sql = sql + ", case a.dm_ptn_8  when 1 then '○' when 0 then '×' else '--' end as news_letter_2 "
    sql = sql + ", SUM(case WHEN attack_states.code = 'S' then 1 else 0 end) as rank_s "
    sql = sql + ", SUM(case WHEN attack_states.code = 'A' then 1 else 0 end) as rank_a "
    sql = sql + ", SUM(case WHEN attack_states.code = 'B' then 1 else 0 end) as rank_b "
    sql = sql + ", SUM(case WHEN attack_states.code = 'C' then 1 else 0 end) as rank_c "
    sql = sql + ", SUM(case WHEN attack_states.code = 'D' then 1 else 0 end) as rank_d "
    sql = sql + ", SUM(case WHEN attack_states.code = 'Z' then 1 else 0 end) as rank_z "
    sql = sql + ", SUM(case WHEN attack_states.code = 'X' then 1 else 0 end) as rank_x "
    sql = sql + ", SUM(case WHEN attack_states.code = 'Y' then 1 else 0 end) as rank_y "
    sql = sql + ", SUM(case WHEN attack_states.code = 'W' then 1 else 0 end) as rank_w "
    sql = sql + "FROM owners a "
    sql = sql + " inner join trusts on a.id = trusts.owner_id "
    sql = sql + " inner join attack_states on trusts.attack_state_id = attack_states.id "
    #    sql = sql + "WHERE  a.biru_user_id = " + object_user.id.to_s + " "
    sql = sql + "WHERE  trusts.biru_user_id = " + object_user.id.to_s + " "
sql = sql + " AND a.delete_flg = 0 "
    sql = sql + " AND trusts.delete_flg = 0 "
    sql = sql + "group by "
    sql = sql + "  a.id "
    sql = sql + " ,a.dm_delivery "
    sql = sql + " ,a.attack_code "
    sql = sql + " ,a.name "
    sql = sql + " ,a.honorific_title "
    sql = sql + " ,a.kana "
    sql = sql + " ,a.postcode "
    sql = sql + " ,a.address "
    sql = sql + " ,a.tel "
    sql = sql + " ,a.memo "
    sql = sql + " ,a.dm_ptn_1 "
    sql = sql + " ,a.dm_ptn_2 "
    sql = sql + " ,a.dm_ptn_3 "
    sql = sql + " ,a.dm_ptn_4 "
    sql = sql + " ,a.dm_ptn_5 "
    sql = sql + " ,a.dm_ptn_6 "
    sql = sql + " ,a.dm_ptn_7 "
    sql = sql + " ,a.dm_ptn_8 "
    sql = sql + " ,a.tel "

    sql = sql + "ORDER BY a.postcode "


  else
    sql = ""
    sql = sql + "SELECT id "
    sql = sql + ", a.attack_code as code "
    sql = sql + ", a.name "
    sql = sql + ", a.address "
    sql = sql + ", a.memo "
    sql = sql + "FROM owners a "
    sql = sql + "WHERE  biru_user_id = " + object_user.id.to_s + " "
    sql = sql + "AND a.delete_flg = 0 "
    sql = sql + "ORDER BY updated_at DESC "
  end
end

def get_buildings_sql(object_user)
  sql = ""
  sql = sql + "SELECT a.id "
  sql = sql + ", a.attack_code as code "
  sql = sql + ", a.name "
  sql = sql + ", a.address "
  sql = sql + ", a.memo "
  sql = sql + ", b.name as shop_name "
  sql = sql + "FROM buildings a inner join shops b on a.shop_id = b.id "
  sql = sql + "WHERE  biru_user_id = " + object_user.id.to_s + " "
  sql = sql + "AND a.delete_flg = 0 "
  sql = sql + "ORDER BY updated_at DESC "
end

# 検索条件を初期化します。
def search_init
  #-----------------------------
  # 検索条件の共通部分を呼び出します。
  #-----------------------------
  search_init_common

  # 検索対象湯ユーザーを取得します
  @biru_users = TrustManagementsController.get_attack_list_search_users(@biru_user)

  @search_param[:rank_s] = true
  @search_param[:rank_a] = true
  @search_param[:rank_b] = true
  @search_param[:rank_c] = true
end


# 受託月報の見込み物件登録用
def report_rank_regist(month_report, trust_attack_history, start_date, end_date, rank_approach_cnt)
  attack_rank = TrustAttackMonthReportRank.unscoped.find_or_create_by_trust_attack_month_report_id_and_trust_id(month_report.id, trust_attack_history.trust_id)

  # trustの削除フラグがONになっていることもあるので、その場合はスキップする。
  unless trust_attack_history.trust
    p "report_rank_regist error: trust_attack_history_id :" + trust_attack_history.id.to_s  + " 委託ID:" + trust_attack_history.trust_id.to_s
    return
  end

  attack_rank.trust_attack_month_report_id = month_report.id
  attack_rank.trust_id = trust_attack_history.trust_id
  attack_rank.owner_id = trust_attack_history.trust.owner.id
  attack_rank.change_month = trust_attack_history.month
  attack_rank.attack_state_this_month_id = trust_attack_history.attack_state_to.id

  # 先月のランクを取得する。(存在しない時は、最新のランクと変わっていないということなので今月時点の最新ランクを設定する)
  last_month = (Date.strptime(month_report.month + "01", "%Y%m%d") << 1).strftime("%Y%m")
  last_month_state = TrustAttackStateHistory.find_by_trust_id_and_month(trust_attack_history.trust_id, last_month)
  if last_month_state
    attack_rank.attack_state_last_month_id = last_month_state.attack_state_to.id
  else

    # もし過去のランクが１件も存在しなければ、当初は未設定ということ。そうでなければそれ以降の変更がないということで今月時点の最新ランクを設定する
    if TrustAttackStateHistory.where("trust_id = " + trust_attack_history.trust_id.to_s + " and month < '" + last_month + "'").count == 0
      attack_rank.attack_state_last_month_id = AttackState.find_by_code("X").id
    else
      attack_rank.attack_state_last_month_id = trust_attack_history.attack_state_to.id
    end

  end

  attack_rank.change_status = AttackState.compare_rank(attack_rank.attack_state_last_month, attack_rank.attack_state_this_month)

  building = trust_attack_history.trust.building

  attack_rank.building_id = building.id
  attack_rank.building_name = building.name

  attack_rank.building_latitude = building.latitude
  attack_rank.building_longitude = building.longitude

  attack_rank.room_num = building.room_num

   # 当月にその見込み物件オーナーにアプローチした件数をカウント(DM除く)
   attack_rank.approach_cnt =  OwnerApproach.joins(:approach_kind).where("owner_approaches.owner_id = " + attack_rank.owner_id.to_s).where("approach_date between ? and ? ", start_date, end_date).where("biru_user_id = ?", month_report.biru_user_id).where("approach_kinds.code in ('0010', '0020', '0025', '0040', '0045')").count

  attack_rank.delete_flg = false
  attack_rank.save!

  # ランクごとのアプローチ件数を保存
  if rank_approach_cnt[trust_attack_history.attack_state_to.code]
    rank_approach_cnt[trust_attack_history.attack_state_to.code] += attack_rank.approach_cnt
  end
end
end
