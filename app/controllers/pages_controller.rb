# -*- encoding:utf-8 -*-

class PagesController < ApplicationController
  # skip_action :auth # バッチでこのページに定期的にアクセスするためここでは認証が行われないようにする。
  def index
    @menu_type = 0
    render layout: "menu"
  end

  def menu01
    @menu_type = 1
    render layout: "menu"
  end

  def menu02
    @menu_type = 2
    render layout: "menu"
  end

  def menu03
    @menu_type = 3
    render layout: "menu"
  end

  def menu04
    @menu_type = 4
    render layout: "menu"
  end

  def menu05
    @menu_type = 7
    render layout: "menu"
  end

  def error_page
  end

  def iss
    @ridirect_type = nil
    @str = "不正なパラメータです"

    # パラメータチェック
    if params[:owner] && num_check(params[:owner])

      owner = Owner.find_by_code(params[:owner])
      unless owner
        @str = "家主CD #{params[:owner]}　は存在しません"
      else
        @str = "オーナー詳細画面 を起動中.....しばらくお待ちください。　※もし5秒以上立ち上がらない場合はすでに別ウィンドウで立ち上がったいる可能性があります。別ウィンドウを閉じてから再度実行してください。"
        @ridirect_type = :owner
        @id = owner.id.to_s
      end

    elsif params[:building] && num_check(params[:building])

      building = Building.find_by_code(params[:building])

      unless building
        @str = "建物CD #{params[:building]}　は存在しません"
      else
        @str = "建物詳細画面 を起動中.....しばらくお待ちください。　※もし5秒以上立ち上がらない場合はすでに別ウィンドウで立ち上がったいる可能性があります。別ウィンドウを閉じてから再度実行してください。"
        @ridirect_type = :building
        @id = building.id.to_s
      end

    elsif params[:keiyaku]
        # オービックから呼ばれる
        @str = "契約詳細画面 を起動中.....しばらくお待ちください。　※もし5秒以上立ち上がらない場合はすでに別ウィンドウで立ち上がったいる可能性があります。別ウィンドウを閉じてから再度実行してください。"
        @ridirect_type = :keiyaku
        @id = params[:keiyaku].to_i

    elsif params[:construction]
        @str = "工事履歴画面 を起動中.....しばらくお待ちください。　※もし5秒以上立ち上がらない場合はすでに別ウィンドウで立ち上がったいる可能性があります。別ウィンドウを閉じてから再度実行してください。"
        @ridirect_type = :construction
        @kouzi_no = params[:construction].to_i

    elsif params[:syuuri]
        # オービックから呼ばれる
        @str = "修理依頼 を起動中.....しばらくお待ちください。　※もし5秒以上立ち上がらない場合はすでに別ウィンドウで立ち上がったいる可能性があります。別ウィンドウを閉じてから再度実行してください。"
        @ridirect_type = :syuuri
        @id = params[:syuuri].to_i

    elsif params[:misyuu_kbn]
        # オービックから呼ばれる
        @str = "工事未収詳細 を起動中.....しばらくお待ちください。　※もし5秒以上立ち上がらない場合はすでに別ウィンドウで立ち上がったいる可能性があります。別ウィンドウを閉じてから再度実行してください。"
        @ridirect_type = :kouji_misyuu

        @misyuu_kbn = params[:misyuu_kbn]
        @seikyuu_no = params[:seikyuu_no]
        @kouji_no = params[:kouji_no]
        @keiyaku_no = params[:keiyaku_no]
        @koumoku_code = params[:koumoku_code]

    end

    render layout: "simple"
  end


  def obic_to_iss
    # TODO:オービックからの遷移チェック

    @ridirect_type = nil
    @str = "不正なパラメータです(obic_to_iss)"

    if params[:PageID] == "Input_Keiyaku_01" || params[:PageID] == "Input_Seikyuu_Kokyaku_02" || params[:PageID] == "Input_KaiyakuTaikyoSeisan_01" || params[:PageID] == "Input_KeiyakuKousin_01" || params[:PageID] == "Input_Kouzi_05"
        @str = "契約詳細画面 を起動中.....しばらくお待ちください。　※もし5秒以上立ち上がらない場合はすでに別ウィンドウで立ち上がったいる可能性があります。別ウィンドウを閉じてから再度実行してください。"
        @ridirect_type = :keiyaku
        @id = params[:KeiyakuNO].to_i

    elsif params[:PageID] == "Input_Yanusi_01" || params[:PageID] == "Input_KaiyakuTaikyoSeisan_03" || params[:PageID] == "Input_Kouzi_04"

      owner = Owner.find_by_code(params[:YanusiCD].to_i)
      unless owner
        @str = "家主CD #{params[:YanusiCD]}　は存在しません"
      else
        @str = "オーナー詳細画面 を起動中.....しばらくお待ちください。　※もし5秒以上立ち上がらない場合はすでに別ウィンドウで立ち上がったいる可能性があります。別ウィンドウを閉じてから再度実行してください。"
        @ridirect_type = :owner
        @id = owner.id.to_s
      end

    elsif params[:PageID] == "Input_KanriItakuKeiyaku_01"

      trust = Trust.find_by_code(params[:KanriItakuKeiyakuNO].to_i)
      unless trust
        @str = "管理委託CD #{params[:KanriItakuKeiyakuNO]}　は存在しません"
      else
        @str = "オーナー詳細画面 を起動中.....しばらくお待ちください。　※もし5秒以上立ち上がらない場合はすでに別ウィンドウで立ち上がったいる可能性があります。別ウィンドウを閉じてから再度実行してください。"
        @ridirect_type = :owner
        @id = trust.owner.id.to_s
      end

    elsif params[:PageID] == "Input_Bukken_01" || params[:PageID] == "Input_KaiyakuTaikyoSeisan_02" || params[:PageID] == "Input_Seikyuu_Bukken_01" || params[:PageID] == "Input_Kouzi_02"

      # building = Building.find_by_code(params[:BukkenCD].to_i)
      building = Building.force_get_by_code(params[:BukkenCD])

      unless building
        @str = "建物CD #{params[:BukkenCD]}　は存在しません"
      else
        @str = "建物詳細画面 を起動中.....しばらくお待ちください"
        @ridirect_type = :building
        @id = building.id.to_s
      end

    elsif params[:PageID] == "Input_Heya_01"
        @ridirect_type = :heya
        @bukken_cd = params[:BukkenCD]
        @heya_no = params[:HeyaNO]

    elsif params[:PageID] == "Input_Kouzi_01" # 工事
      @ridirect_type = :construction
      @kouzi_no = params[:KouziNO]
    end

    render "iss", layout: "simple"
  end


  def num_check(str_num)
    str_num =~ /^\d+$/
  end
end
