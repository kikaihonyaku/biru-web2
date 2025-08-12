# -*- coding:utf-8 -*-

require "kconv"
require "date"
require "moji"
require "digest/md5"

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protect_from_forgery with: :exception

  # 2014/06/02
  # change_biru_iconはrailsのformではなくhtmlのformで直接送ってくるから
  # biru_userセッションを参照できない。それによってログインへリダイレクトされると
  # 直前の地図凡例変更のイベントが失われてしまう。change_biru_iconだけは例外扱いとする。
  #
  # 2014/06/02 追記
  # 一度sessionがクリアされてしまうと次検索した時に必ずログイン画面になってしまう。
  # 検索条件もリセットされてしまうので使い勝手が悪いので、managementsコントローラの時は
  # もうチェックしないようにする。（良い対策ができるまで）
  # before_action :check_logined, :except => ['change_biru_icon', 'search_owners', 'search_buildings', 'bulk_search_text']

  # 2014/06/10 paramでuser_idを送るようにして対応できた。
  before_action :check_logined

  # CSV出力する際、Windowsで開くためにShift_JISに変換する。■2014/08/12 当面はpdfで出力するため、文字コードはutf-8に戻す。
  after_action :change_charset_to_sjis, if: :csv?


  # 建物用のハッシュを取得します
  def conv_code_building(user_id, address, name)
    conv_code(user_id + "_" + address + "_" + name)
  end

  # 貸主用のハッシュを取得します
  def conv_code_owner(user_id, address, name)
    conv_code(user_id + "_" + address + "_" + name)
  end

  # カレントの月度を返す(offsetは集計期間をずらす)
  def get_cur_month(offset = 0)
    # 当月の月を出す。
    if Date.today.day > 20 + offset
      # 翌月
      cur_date = Date.today.next_month
    else
      # 当月
      cur_date = Date.today
    end

     month = "%04d%02d"%[ cur_date.year.to_s, cur_date.month.to_s ]
  end

  # 月度の開始日を取得
  def get_month_day_start(month)
      # 月度(yyyymm)から前月を取得
      Date.strptime(month+"01", "%Y%m%d").months_since(-1).strftime("%Y-%m-21")
  end

  # 月度の終了日を取得
  def get_month_day_end(month)
      # 月度(yyyymm)から当月の20日を取得
      Date.strptime(month+"01", "%Y%m%d").strftime("%Y-%m-20")
  end

  # geocoding
  # force:強制的にgeocodingを行う。
  def biru_geocode(biru, force)
    msg = ""
    begin

      # 住所が空白のみだったらそもそもgeocodeを行わない
      if biru.address.gsub(" ", "").gsub("　", "").length == 0
        msg = "住所が空白のみなのでスキップ "
        raise # 例外発生させrescueへ飛ばす
      end

      skip_flg = biru.gmaps
      skip_flg = false if force

      unless skip_flg
        gmaps_ret = Gmaps4rails.geocode(biru.address)
        biru.latitude = gmaps_ret[0][:lat]
        biru.longitude = gmaps_ret[0][:lng]
        biru.gmaps = true

        #      if biru.code
        #        p format("%05d",biru.code) + ':' + biru.name + ':' + biru.address
        #      else
        #        p format("%05d",biru.attack_code) + ':' + biru.name + ':' + biru.address
        #      end
      end
    rescue => e
      if biru.name.nil? or biru.address.nil?
        p e
      else
        p e
      end

      # エラー処理
      biru.gmaps = false
      biru.delete_flg = true

    end

    msg
  end


  # nilの時は0を返す
  def nz(value)
    result = nil
    if value
      result = value
    else
      result = 0
    end

    result
  end

  protected
  def change_charset_to_sjis
    response.body = NKF.nkf("-Ws", response.body)
    headers["Content-Type"] = "text/html; charset=Shift_JIS"
  end

  private

  # ログイン認証を行います。
  def check_logined
    login_code = ""

    # 呼び出し元のウィンドウクローズチェック
    if params[:close]
      @close_window_name = params[:close]
    else
      @close_window_name = ""
    end

    url_param_delete = false

    if session[:biru_user]
      user_id = session[:biru_user]
    elsif params[:user_id]
      user_id = params[:user_id].to_i
    elsif params[:sid]
      user_id = BiruUser.find_by_syain_id(params[:sid])
      url_param_delete = true

      if user_id
        # ログの保存
        log = LoginHistory.new
        log.biru_user_id = user_id.id
        log.code = user_id.code
        log.name = user_id.name
        log.save!
      end

    elsif params[:UserID]
      # 未ログイン状態でかつ、UserIDが入っていたら、ログインフォームでデフォルトで表示させる。
      login_code = params[:UserID]
    else
      user_id = nil
    end

    if user_id then
      begin
        @biru_user = BiruUser.find(user_id)
        session[:biru_user] = @biru_user
      rescue ActiveRecord::RecordNotFound
        reset_session
      end
    end

    unless @biru_user
      flash[:referer] = request.fullpath

      if login_code == ""
      redirect_to controller: "login", action: "index", referer: request.fullpath
      else
        redirect_to controller: "login", action: "index", login_code: login_code, referer: request.fullpath
      end
    end

    # URLパラメータを消すためにリダイレクトする
    #    if url_param_delete
    #      endpos = request.fullpath.index("?") - 1
    #      redirect_to request.fullpath[0..endpos]
    #    end
  end

  # 管理／募集画面で、検索結果の初期表示を制御するのに使用します。
  # search_type 1:建物 2:貸主 を初期表示
  def search_result_init(search_type)
    @search_type = search_type
    @tab_search = ""
    @tab_result = "active in"
  end

  def trust_managements?
    self.controller_name == "trust_managements"
  end

  def csv?
    request.original_url.match(/csv/) ? true : false
  end

  # 文字列の日付が正しいかチェックします
  def date_check(str_date)
    result = true

    begin
      Date.parse(str_date)
    rescue => ex
      result = false
    end

    result
  end

  # 指定した建物情報を元に、出力用のjavascriptオブジェクトを作成します。
  def buildings_to_gon(buildings)
      @manage_line_color = make_manage_line_list

      if buildings.size == 0
        # 表示する建物が存在しない時
        @owners = []
        @trusts = []
        @owner_to_buildings = {}
        @building_to_owners = {}
        @shops =  Shop.find(:all)

      else

        # 建物にマーカーを設定
        set_biru_obj(buildings)
        @buildings = buildings

        # 建物に紐づく貸主／委託契約を取得(合わせて管理方式の絞り込み)
        @shops, @owners, @trusts, @owner_to_buildings, @building_to_owners = get_building_info(buildings)

      end

      gon.buildings = buildings
      gon.owners = @owners # 関連する貸主
      gon.trusts = @trusts # 関連する委託契約
      gon.shops = @shops    # 関連する営業所
      gon.owner_to_buildings = @owner_to_buildings # 建物と貸主をひもづける情報
      gon.building_to_owners = @building_to_owners
      gon.manage_line_color = @manage_line_color
      gon.all_shops = Shop.find(:all)
  end

  # 指定された建物に紐づく営業所・貸主・委託情報を取得する
  def get_building_info(buildings)
    shops = []
    owners = []
    trusts = []
    owner_to_buildings = []
    building_to_owners = []

    buildings.each do |biru|
      shops << biru.shop if biru.shop

      biru.trusts.each do |trust|
        trusts << trust

        # 貸主登録
        if trust.owner
          tmp_owner = trust.owner
          owners << tmp_owner

          # 貸主に紐づく建物一覧を作成する。
          owner_to_buildings[tmp_owner.id] = [] unless owner_to_buildings[tmp_owner.id]
          owner_to_buildings[tmp_owner.id] << biru

          # 建物に紐づく貸主一覧を作成する。※本来建物に対するオーナーは１人だが、念のため複数オーナーも対応する。
          building_to_owners[biru.id] = [] unless building_to_owners[biru.id]
          building_to_owners[biru.id] << tmp_owner
        end
      end
    end

    owners.uniq! if owners
    trusts.uniq! if trusts
    shops.uniq! if shops

    return shops, owners, trusts, owner_to_buildings, building_to_owners
  end

  # 管理方式のIDに応じた色リストを作成する
  def make_manage_line_list
    arr = []
    ManageType.all.each do |manage_type|
      arr[manage_type.id] = manage_type.line_color
    end

    arr
  end

  # 建物インスタンスに物件種別・管理方式を設定する。
  def set_biru_obj(buildings)
    buildings.each do |biru|
      if biru.build_type
        biru.tmp_build_type_icon = biru.build_type.icon
      else
        # biru.tmp_build_type_icon = 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%e4%b8%8d|00FF00|000000'
        biru.tmp_build_type_icon = view_context.image_path("marker_white.png")
      end

      if biru.trusts
        biru.trusts.each do |trust|
          if trust.manage_type
            biru.tmp_manage_type_icon = trust.manage_type.icon
          end
        end
      end
    end
  end


  # アタック建物コードやアタック貸主コードの生成に使用
  # def attack_conv_code(user_id, address, name)
  #
  #   str = user_id.to_s + '_' + address + '_' + name
  #
  #   str = str.gsub(/(\s|　)+/, '')
  #   str = str.upcase
  #   str = Moji.han_to_zen(str.encode('utf-8'))
  #
  #  # ハッシュ化して先頭6文字を取得
  #  return Digest::MD5.new.update(str).to_s[0,5]
  # end

  # コード用に変換方法を統一
  def conv_code(str)
    str = str.gsub(/(\s|　)+/, "")
    str = str.upcase
    str = Moji.han_to_zen(str.encode("utf-8"))

   # ハッシュ化
   Digest::MD5.new.update(str).to_s
  end

  # 指定された日のポラスの月度を取得する
  def get_month(cur_date)
    if cur_date.day > 20
      # 日付が21日以降だったら翌月
      cur_date.next_month.strftime("%Y%m")
    else
      # それ以外だったら当月
      cur_date.strftime("%Y%m")
    end
  end

  # jqgridの営業所リストを返す
  def jqgrid_combo_shop
    result = ":"
    Shop.order(:group_id,  :area_id).each do |shop|
      result = result + ";" + shop.name + ":" + shop.name
    end
    result
  end

  # jqgridの建物種別のリストを返す
  def jqgrid_combo_build_type
    result = ":"
    BuildType.find(:all).each do |obj|
      result = result + ";" + obj.name + ":" + obj.name
    end
    result
  end

  # jqgridの管理方式のリストを返す
  def jqgrid_combo_manage_type
    result = ":"
    ManageType.find(:all).each do |obj|
      result = result + ";" + obj.name + ":" + obj.name
    end
    result
  end

  # jqgridのアプローチ種別のリストを返す
  def jqgrid_combo_approach_kind
    result = ":"
    ApproachKind.order(:sequence).each do |obj|
      result = result + ";" + obj.name + ":" + obj.name
    end
    result
  end

  def jqgrid_combo_rank
    result = ":"
    AttackState.all.each do |obj|
      result = result + ";" + obj.code + ":" + obj.name
    end
    result
  end


  # 検索条件の共通部品
  def search_init_common
    @error_msg = []
    @search_param = {}

    #--------------------------------
    # 管理営業所
    #--------------------------------
    @shops = Shop.all

    #---------------
    # 訪問リレキ
    #---------------
    @history_visit = {}
    @history_visit[:all] = false
    @history_visit[:exist] = false
    @history_visit[:not_exist] = false

    if params[:history_visit]
      @history_visit[params[:history_visit].to_sym] = true
    else
      @history_visit[:all] = true
    end

    @history_visit_from = Date.today().strftime("%Y/%m/%d")
    @history_visit_to = Date.today().strftime("%Y/%m/%d")

    if params[:history_visit_from]
      @history_visit_from =  params[:history_visit_from]

      unless date_check(@history_visit_from)
        @error_msg.push("訪問リレキ(FROM)に不正な日付が入力されました。")
      end

    end

    if params[:history_visit_to]
      @history_visit_to =  params[:history_visit_to]

      unless date_check(@history_visit_to)
        @error_msg.push("訪問リレキ(TO)に不正な日付が入力されました。")
      end
    end

    #---------------------
    # ダイレクトメールリレキ
    #---------------------
    @history_dm = {}
    @history_dm[:all] = false
    @history_dm[:exist] = false
    @history_dm[:not_exist] = false

    if params[:history_dm]
      @history_dm[params[:history_dm].to_sym] = true
    else
      @history_dm[:all] = true
    end

    @history_dm_from = Date.today().strftime("%Y/%m/%d")
    @history_dm_to = Date.today().strftime("%Y/%m/%d")

    if params[:history_dm_from]
      @history_dm_from =  params[:history_dm_from]

      unless date_check(@history_dm_from)
        @error_msg.push("ＤＭリレキ(FROM)に不正な日付が入力されました。")
      end
    end

    if params[:history_dm_to]
      @history_dm_to =  params[:history_dm_to]

      unless date_check(@history_dm_to)
        @error_msg.push("ＤＭリレキ(TO)に不正な日付が入力されました。")
      end

    end

    #---------------
    # 電話リレキ
    #---------------
    @history_tel = {}
    @history_tel[:all] = false
    @history_tel[:exist] = false
    @history_tel[:not_exist] = false

    if params[:history_tel]
      @history_tel[params[:history_tel].to_sym] = true
    else
      @history_tel[:all] = true
    end

    @history_tel_from = Date.today().strftime("%Y/%m/%d")
    @history_tel_to = Date.today().strftime("%Y/%m/%d")

    if params[:history_tel_from]
      @history_tel_from =  params[:history_tel_from]

      unless date_check(@history_tel_from)
        @error_msg.push("ＴＥＬリレキ(FROM)に不正な日付が入力されました。")
      end

    end

    if params[:history_tel_to]
      @history_tel_to =  params[:history_tel_to]

      unless date_check(@history_tel_to)
        @error_msg.push("ＴＥＬリレキ(TO)に不正な日付が入力されました。")
      end

    end
  end
end
