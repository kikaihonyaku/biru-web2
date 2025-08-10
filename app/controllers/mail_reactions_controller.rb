#-*- encoding:utf-8 -*- 
require 'date'
class MailReactionsController < ApplicationController

  def index
  end

  def new
    @mail_reaction = MailReaction.new

    # 初期値の設定      
    if params[:month]
      @mail_reaction.月度 = params[:month]
    end

    if params[:busyo_id]
      @mail_reaction.部署ID = params[:busyo_id]
    end

    init # コンボボックスなどを作成

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @mail_reaction }
    end
  end

  # POST /biru_users
  # POST /biru_users.json
  def create
    # @mail_reaction = MailReaction.new(params[:mail_reaction]) # ←２バイト文字だとうまくいかない？

    @mail_reaction = MailReaction.new

    # 登録・更新内容の詰め込み
    set_mail_reaction_base()

    @mail_reaction.基本_登録者名 = @biru_user.name
    @mail_reaction.基本_登録日時 = DateTime.now.strftime('%Y/%m/%d/ %H:%M:%S')
    
    @mail_reaction.基本_更新者名 = @biru_user.name
    @mail_reaction.基本_更新日時 = DateTime.now.strftime('%Y/%m/%d/ %H:%M:%S')

    respond_to do |format|
      if @mail_reaction.save
        flash[:notice] = @mail_reaction.問合せ氏名 + "様 物件：" + @mail_reaction.問合せ物件 + " 登録しました"
        format.html { redirect_to action: "new", month:@mail_reaction.月度, busyo_id:@mail_reaction.部署ID, notice: '登録完了しました.' }
        format.json { render json: @mail_reaction, status: :created, location: @mail_reaction }
      else
        init
        format.html { render action: "new" }
        format.json { render json: @mail_reaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /biru_users/1/edit
  def edit

    @mail_reaction = MailReaction.find(params[:id])
    if @mail_reaction.受信日時
      @tmp_受信日付 = @mail_reaction.受信日時.strftime('%Y/%m/%d')
      @tmp_受信時刻 = @mail_reaction.受信日時.strftime('%H:%M')

      # 曜日を出す
      @tmp_受信日付曜日 = %w(日 月 火 水 木 金 土)[@mail_reaction.受信日時.wday] + '曜日'

    end

    if @mail_reaction.返信_返信日時
      @tmp_返信日付 = @mail_reaction.返信_返信日時.strftime('%Y/%m/%d')
      @tmp_返信時刻 = @mail_reaction.返信_返信日時.strftime('%H:%M')
    end

    if @mail_reaction.営業所_メール返信日付
      @tmp_営業所_メール返信日付 = @mail_reaction.営業所_メール返信日付.strftime('%Y/%m/%d')
    end

    if @mail_reaction.営業所_来店日付
      @tmp_営業所_来店日付 = @mail_reaction.営業所_来店日付.strftime('%Y/%m/%d')
    end

    if @mail_reaction.営業所_案内日付
      @tmp_営業所_案内日付 = @mail_reaction.営業所_案内日付.strftime('%Y/%m/%d')
    end

    if @mail_reaction.営業所_申込日付
      @tmp_営業所_申込日付 = @mail_reaction.営業所_申込日付.strftime('%Y/%m/%d')
    end

    init # コンボボックスなどを作成

  end

  # 
  def update

    @mail_reaction = MailReaction.find(params[:mail_reaction][:メール反響ID])
    
    # 登録・更新内容の詰め込み
    set_mail_reaction_base()

    @mail_reaction.基本_更新者名 = @biru_user.name
    @mail_reaction.基本_更新日時 = DateTime.now.strftime('%Y/%m/%d/ %H:%M:%S')

    respond_to do |format|
      if @mail_reaction.save
        flash[:notice] = @mail_reaction.問合せ氏名 + "　様 　　" + @mail_reaction.問合せ物件 + " 更新しました"
        format.html { redirect_to action: "edit", id: @mail_reaction.メール反響ID }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @mail_reaction.errors, status: :unprocessable_entity }
      end
    end    
  end

  # 営業所欄の更新
  def update_shop

    @mail_reaction = MailReaction.find(params[:mail_reaction][:メール反響ID])
    
    # 登録・更新内容の詰め込み(営業所用)
    set_mail_reaction_shop()

    @mail_reaction.営業所_更新者名 = @biru_user.name
    @mail_reaction.営業所_更新日時 = DateTime.now.strftime('%Y/%m/%d/ %H:%M:%S')

    respond_to do |format|
      if @mail_reaction.save
        flash[:notice] = @mail_reaction.問合せ氏名 + "　様 　　" + @mail_reaction.問合せ物件 + " 更新しました"
        format.html { redirect_to action: "edit", id: @mail_reaction.メール反響ID }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @mail_reaction.errors, status: :unprocessable_entity }
      end
    end    
  end

  # 返信時間の更新
  def update_response

    @mail_reaction = MailReaction.find(params[:mail_reaction][:メール反響ID])
    
    # 登録・更新内容の詰め込み(営業所用)
    set_mail_reaction_response()

    @mail_reaction.返信_更新者名 = @biru_user.name
    @mail_reaction.返信_更新日時 = DateTime.now.strftime('%Y/%m/%d/ %H:%M:%S')

    respond_to do |format|
      if @mail_reaction.save
        flash[:notice] = @mail_reaction.問合せ氏名 + "　様 　　" + if @mail_reaction.問合せ物件 then @mail_reaction.問合せ物件 else "" end  + " 更新しました"
        format.html { redirect_to action: "edit", id: @mail_reaction.メール反響ID }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @mail_reaction.errors, status: :unprocessable_entity }
      end
    end    
  end

  def delete_update
    @mail_reaction = MailReaction.find(params[:mail_reaction][:メール反響ID])
    @mail_reaction.削除フラグ = true
    @mail_reaction.save!


    respond_to do |format|
      if @mail_reaction.save
        flash[:notice] = @mail_reaction.問合せ氏名 + "　様 　　" + if @mail_reaction.問合せ物件 then @mail_reaction.問合せ物件 else "" end  + " 削除フラグをONにしました"
        format.html { redirect_to action: "edit", id: @mail_reaction.メール反響ID }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @mail_reaction.errors, status: :unprocessable_entity }
      end
    end    
  end
  

private
  def init

      # 営業所リスト
      @dept_list = []
      @dept_list.push([])

      # ↓部署IDの設定してある内容が違ったのでコメントM_部署からとるようにする。
      # Dept.where("name like '%営業所'").order('sort_num').each do |dpt|
      #   rec = []
      #   rec.push(dpt.name)
      #   rec.push(dpt.busyo_id)
      #   @dept_list.push(rec)
      # end

      sql = ""
      sql = sql + "SELECT 部署ID, 部署名 "
      sql = sql + "FROM BIRU31.biru.M_部署 "
      sql = sql + "WHERE 営業所フラグ = 1 "
      sql = sql + "AND エリアフラグ = 0 "
      sql = sql + "AND 支店フラグ = 0 "  
      sql = sql + "ORDER BY 表示順 "
      ActiveRecord::Base.connection.select_all(sql).each do |dpt|
        rec = []
        rec.push(dpt['部署名'])
        rec.push(dpt['部署ID'])
        @dept_list.push(rec)
    end
      

      # 反響サイトコード
      @site_list = []
      @site_list.push([])
      sql = ""
      sql = sql + "SELECT 反響サイトコード, 反響サイト名 "
      sql = sql + "FROM BIRU31.biru.M_反響サイト "
      sql = sql + "ORDER BY 反響サイトコード "

      ActiveRecord::Base.connection.select_all(sql).each do |site|
        rec = []
        rec.push(site['反響サイト名'])
        rec.push(site['反響サイトコード'])
        @site_list.push(rec)
      end
  end

  # 基本の登録更新内容を詰め込みます。
  def set_mail_reaction_base

    @mail_reaction.部署ID = params[:mail_reaction][:部署ID]
    @mail_reaction.月度 = params[:mail_reaction][:月度]  
    @mail_reaction.反響サイトコード = params[:mail_reaction][:反響サイトコード]

    @tmp_受信日付 = params[:受信日付]
    @tmp_受信時刻 = params[:受信時刻]

    if @tmp_受信時刻.length == 4
      @tmp_受信時刻 = @tmp_受信時刻[0..1] + ':' + @tmp_受信時刻[2..3]
    end

    @mail_reaction.受信日時 = nil
    if @tmp_受信日付 != '' && @tmp_受信時刻 =~ /^([0-1][0-9]|[2][0-3]):[0-5][0-9]$/
      @mail_reaction.受信日時 = @tmp_受信日付 + ' ' + @tmp_受信時刻 # 不正な日付は登録時にvalidationエラー
    end

    @mail_reaction.問合せ氏名 = params[:mail_reaction][:問合せ氏名]
    @mail_reaction.問合せ物件 = params[:mail_reaction][:問合せ物件]
    @mail_reaction.重複フラグ = params[:mail_reaction][:重複フラグ]
    @mail_reaction.反響種別 = params[:mail_reaction][:反響種別]
    @mail_reaction.掲載種別 = params[:mail_reaction][:掲載種別]
    @mail_reaction.駅 = params[:mail_reaction][:駅]
    @mail_reaction.徒歩 = params[:mail_reaction][:徒歩]
    @mail_reaction.バス = params[:mail_reaction][:バス]
    @mail_reaction.間取り = params[:mail_reaction][:間取り]
    @mail_reaction.賃料 = params[:mail_reaction][:賃料]
    @mail_reaction.築年月 = params[:mail_reaction][:築年月]
    @mail_reaction.名寄点数 = params[:mail_reaction][:名寄点数]
    @mail_reaction.名寄順位 = params[:mail_reaction][:名寄順位]
    @mail_reaction.元付け業者名 = params[:mail_reaction][:元付け業者名]
    @mail_reaction.備考 = params[:mail_reaction][:備考]
    
  end
  
  # 営業所入力欄を更新します。
  def set_mail_reaction_shop

    @mail_reaction.営業所_担当 = params[:mail_reaction][:営業所_担当]
    @mail_reaction.営業所_備考 = params[:mail_reaction][:営業所_備考]
    @mail_reaction.営業所_メール返信有無 = params[:mail_reaction][:営業所_メール返信有無]
    @mail_reaction.営業所_来店有無 = params[:mail_reaction][:営業所_来店有無]
    @mail_reaction.営業所_案内有無 = params[:mail_reaction][:営業所_案内有無]
    @mail_reaction.営業所_申込有無 = params[:mail_reaction][:営業所_申込有無]

    @mail_reaction.営業所_メール返信日付 = params[:営業所_メール返信日付]
    @mail_reaction.営業所_来店日付 = params[:営業所_来店日付]
    @mail_reaction.営業所_案内日付 = params[:営業所_案内日付]
    @mail_reaction.営業所_申込日付 = params[:営業所_申込日付]

  end

  # 返信時間を設定します。
  def set_mail_reaction_response
    
    @tmp_返信日付 = params[:返信_返信日付]
    @tmp_返信時刻 = params[:返信_返信時刻]
    @mail_reaction.直接電話 = params[:mail_reaction][:直接電話]
    @mail_reaction.定休日 = params[:mail_reaction][:定休日]

    if @tmp_返信時刻.length == 4
      @tmp_返信時刻 = @tmp_返信時刻[0..1] + ':' + @tmp_返信時刻[2..3]
    end

    @mail_reaction.返信_返信日時 = nil
    if @tmp_返信日付 != '' && @tmp_返信時刻 =~ /^([0-1][0-9]|[2][0-3]):[0-5][0-9]$/
      @mail_reaction.返信_返信日時 = @tmp_返信日付 + ' ' + @tmp_返信時刻
    end

    # if params[:mail_reaction][:返信_単純返信時間] != '' && params[:mail_reaction][:返信_単純返信時間] != '00:00'
    #   @mail_reaction.返信_単純返信時間 = params[:mail_reaction][:返信_単純返信時間] + ":00"
    # else
    #   @mail_reaction.返信_単純返信時間 = nil
    # end

    # if params[:mail_reaction][:返信_稼働考慮返信時間] != '' && params[:mail_reaction][:返信_稼働考慮返信時間] != '00:00'
    #   @mail_reaction.返信_稼働考慮返信時間 = params[:mail_reaction][:返信_稼働考慮返信時間] + ":00"
    # else
    #   @mail_reaction.返信_稼働考慮返信時間 = nil
    # end

    @mail_reaction.返信_単純返信時間 = params[:mail_reaction][:返信_単純返信時間]
    @mail_reaction.返信_稼働考慮返信時間 = params[:mail_reaction][:返信_稼働考慮返信時間]

  end
    
end
