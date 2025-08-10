#-*- coding:utf-8 -*-

class ConstructionsController < ApplicationController

  def popup
    @construction = Construction.find_or_create_by_code(params[:code])
    @construction.code = params[:code]

    # 工事コードから物件を取得する。
    sql = ""
    sql = sql + "SELECT BukkenCD "
    sql = sql + ", BukkenName "
    sql = sql + ", IsNull(HeyaNO,'') HeyaNO"
    sql = sql + ", KanriItakuKeiyakuNO"
    sql = sql + ", YanusiCD"
    sql = sql + ", YanusiName"
    sql = sql + ", KeiyakuNO"
    sql = sql + ", KeiyakushaName"
    sql = sql + ", KihonUriageKeijouYoteiDate"
    sql = sql + ", KihonUriageKeijouDate"
    sql = sql + ", KouziShubetuName"
    sql = sql + ", KouziName"
    sql = sql + ", Tantousha1CD"
    sql = sql + ", Tantousha1Name"
    sql = sql + ", KeiyakuYoteiDate"
    sql = sql + ", KeiyakuDate"
    sql = sql + ", GyoushaIraiDate"
    sql = sql + ", HacchuuYoteiDate"
    sql = sql + ", HacchuuDate"
    sql = sql + ", KouziKanryouYoteiDate"
    sql = sql + ", KouziKanryouDate"
    sql = sql + ", IsNull(Bikou,'') Bikou"
    sql = sql + ", UpdateDatetime"
    sql = sql + ", UpdateTantoushaCD"
    sql = sql + ", UpdateTantoushaName "
    sql = sql + " FROM biru.OBIC_VW_KoujiJouhou X "
    sql = sql + " where KouziNO = '" + ("000000000000" + @construction.code)[-12..-1] + "'"
      
    ActiveRecord::Base.connection.select_all(sql).each do |kouji_jouhou|

      @building = Building.unscoped.find_by_code(kouji_jouhou["BukkenCD"].to_i)
      gon.building = @building
      @trust = Trust.find_by_building_id(@building.id)
  
      @obic_BukkenCD = kouji_jouhou["BukkenCD"]
      @obic_BukkenName = kouji_jouhou["BukkenName"]
      @obic_HeyaNO = kouji_jouhou["HeyaNO"]
      @obic_KanriItakuKeiyakuNO = kouji_jouhou["KanriItakuKeiyakuNO"]
      @obic_YanusiCD = kouji_jouhou["YanusiCD"]
      @obic_YanusiName = kouji_jouhou["YanusiName"]
      @obic_KeiyakuNO = kouji_jouhou["KeiyakuNO"]
      @obic_KeiyakushaName = kouji_jouhou["KeiyakushaName"]
      @obic_KihonUriageKeijouYoteiDate = kouji_jouhou["KihonUriageKeijouYoteiDate"]
      @obic_KihonUriageKeijouDate = kouji_jouhou["KihonUriageKeijouDate"]
      @obic_KouziShubetuName = kouji_jouhou["KouziShubetuName"]
      @obic_KouziName = kouji_jouhou["KouziName"]
      @obic_Tantousha1CD = kouji_jouhou["Tantousha1CD"]
      @obic_Tantousha1Name = kouji_jouhou["Tantousha1Name"]
      @obic_KeiyakuDate = kouji_jouhou["KeiyakuDate"]
      @obic_GyoushaIraiDate = kouji_jouhou["GyoushaIraiDate"]
      @obic_KeiyakuYoteiDate = kouji_jouhou["KeiyakuYoteiDate"]
      @obic_HacchuuYoteiDate = kouji_jouhou["HacchuuYoteiDate"]
      @obic_HacchuuDate = kouji_jouhou["HacchuuDate"]
      @obic_KouziKanryouYoteiDate = kouji_jouhou["KouziKanryouYoteiDate"]
      @obic_KouziKanryouDate = kouji_jouhou["KouziKanryouDate"]
      @obic_Bikou = kouji_jouhou["Bikou"]
      @obic_UpdateDatetime = kouji_jouhou["UpdateDatetime"]
      @obic_UpdateTantoushaCD = kouji_jouhou["UpdateTantoushaCD"]
      @obic_UpdateTantoushaName = kouji_jouhou["UpdateTantoushaName"]
      
    end


    # 工事補足情報
    @kouji_hosoku = []
    sql = ""
    sql = sql + "SELECT "
    sql = sql + " HosokuKoumoku "
    sql = sql + " FROM biru.OBIC_VW_KoujiHosokuJouhou X "
    sql = sql + " where KouziNO = '" + ("000000000000" + @construction.code)[-12..-1] + "'"
    sql = sql + " order by GyouNO  "
    
    ActiveRecord::Base.connection.select_all(sql).each do |hosoku|
      @kouji_hosoku.push(hosoku["HosokuKoumoku"])
    end

    # 工事業者情報
    @kouji_meisai = []
    current_gyousha = ""
    gyousha_koumoku = nil

    sql = ""
    sql = sql + "SELECT "
    sql = sql + " GyoushaCD "
    sql = sql + ",GyoushaName "
    sql = sql + ",GyouNO "
    sql = sql + ",MAX(KouziKanryouDate) As KouziKanryouDate "
    sql = sql + ",KouziKoumokuName "
    sql = sql + ",GenkaZeikomiKingaku "
    sql = sql + ",ZissiKBNName "
    sql = sql + " FROM biru.OBIC_VW_KoujiMeisaiJouhou "
    sql = sql + " WHERE KouziNO = '" + ("000000000000" + @construction.code)[-12..-1] + "'"
    sql = sql + "   AND GyoushaCD IS NOT NULL"
    sql = sql + " GROUP BY GyoushaCD, GyoushaName, GyouNO "
    sql = sql + "  ,KouziKoumokuName "
    sql = sql + "  ,GenkaZeikomiKingaku "
    sql = sql + "  ,ZissiKBNName "
    sql = sql + " ORDER BY GyoushaCD, GyoushaName, GyouNO "

    ActiveRecord::Base.connection.select_all(sql).each do |meisai|

      if current_gyousha != meisai["GyoushaCD"]

        # 業者CDが切り替わったとき
        current_gyousha = meisai["GyoushaCD"]

        construction_scheduled_date = nil # 着工予定日
        construction_date = nil           # 着工日
        completion_scheduled_date = nil   # 完了予定日
        comment = nil                     # コメント
      
        # 工事番号と業者CDで保存された「construction_vendor」モデルを検索
        vendor = ConstructionVendor.find_by_construction_id_and_vendor_code(@construction.id, meisai["GyoushaCD"])
        if vendor
          construction_scheduled_date = vendor.construction_scheduled_date
          construction_date = vendor.construction_date
          completion_scheduled_date = vendor.completion_scheduled_date
          comment = vendor.comment
        end
  
        gyousha_koumoku = []
        @kouji_meisai.push(
          { "GyoushaCD"=> meisai["GyoushaCD"] ,"GyoushaName"=> meisai["GyoushaName"] ,"KouziKanryouDate"=> meisai["KouziKanryouDate"],"construction_scheduled_date"=> construction_scheduled_date,"construction_date"=> construction_date,"completion_scheduled_date"=> completion_scheduled_date, "gyousha_koumoku"=>gyousha_koumoku, "comment"=>comment}
        )
      end

      # 業者別の項目単位の追加
      gyousha_koumoku.push({"KouziKoumokuName"=> meisai["KouziKoumokuName"], "GenkaZeikomiKingaku"=> meisai["GenkaZeikomiKingaku"] , "ZissiKBNName"=> meisai["ZissiKBNName"]})

    end
    
    @construction_approaches = initialize_grid(ConstructionApproach.joins(:construction).includes(:biru_user).where(:construction_id => @construction).order("construction_approaches.updated_at desc") )
    
    user_list = []
    BiruUser.where("name not like '%※%'").each do |user|
      rec = {}
      rec['id'] = user.id
      rec['text'] = ("00000" + user.code)[-5..-1] + ' / ' + user.name
      user_list.push(rec)
    end

    gon.user_list = user_list
    
    render :layout=>'popup'
  end

  def popup_update
    @construction = Construction.find_by_code(params[:code])
    if @construction
      # 更新
      @construction.update_attributes(params[:construction])
      #flash[:notice] = '更新しました。'
    else
      # 新規登録
      @construction = Construction.new(params[:construction])
      #flash[:notice] = '新規登録しました。'
    end
    @construction.save
    
    # 更新履歴を登録
    content = "完了チェック担当者：【"
    content += BiruUser.find( params[:construction][:completion_check_user_id].to_i).name
    content += "】 | 完了チェック予定日：【"
    content += params[:construction][:completion_check_expected_date]
    content += "】 | 完了チェック実施日：【"
    content += params[:construction][:completion_check_date]
    content += "】 | 是正有無：【"
    content += if params[:construction][:correction] == '0' then 'なし' elsif params[:construction][:correction] == '1' then 'あり' else '未設定' end
    content += "】"
    
    construction_approach = ConstructionApproach.new()
    construction_approach.construction_id = @construction.id
    construction_approach.approach_kind_id = ApproachKind.find_by_code('0210').id
    construction_approach.biru_user_id = @biru_user.id
    construction_approach.content = content
    construction_approach.save

    redirect_to :action=>'popup', :code=>@construction.code
  end

  # アプローチ履歴を登録する
  def construction_approach_regist 
    construction_approach = ConstructionApproach.new(params[:construction_approach])
    construction_approach.save!

    construction = construction_approach.construction
    redirect_to :action => 'popup', :code => construction.code
  end
  
  # アプローチリレキを削除する
  def construction_approach_delete
    construction_approach = ConstructionApproach.find(params[:id].to_i)
    construction_approach.delete_flg = true
    construction_approach.save!
    
    construction = construction_approach.construction
    redirect_to :action => 'popup', :code => construction.code
  end

  # 業者の日付を登録する。
  def construction_vendor_update

    construction = Construction.find(params[:construction_id])

    vendor = ConstructionVendor.find_or_create_by_construction_id_and_vendor_code(params[:construction_id], params[:vendor_code])
    vendor.construction_id = params[:construction_id]
    vendor.construction_code = construction.code
    vendor.vendor_code = params[:vendor_code]
    vendor.construction_scheduled_date = params[:construction_vendor][:construction_scheduled_date]
    vendor.construction_date = params[:construction_vendor][:construction_date]
    vendor.completion_scheduled_date = params[:construction_vendor][:completion_scheduled_date]
    vendor.comment = params[:construction_vendor][:comment]
    vendor.updated_biru_user_id = @biru_user.id
    vendor.save!

    redirect_to :action => 'popup', :code => construction.code
    
  end

  


  # GET /constructions
  # GET /constructions.json
  def index
    @constructions = Construction.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @constructions }
    end
  end

  # GET /constructions/1
  # GET /constructions/1.json
  def show
    @construction = Construction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @construction }
    end
  end

  # GET /constructions/new
  # GET /constructions/new.json
  def new
    @construction = Construction.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @construction }
    end
  end

  # GET /constructions/1/edit
  def edit
    @construction = Construction.find(params[:id])
  end

  # POST /constructions
  # POST /constructions.json
  def create
    @construction = Construction.new(params[:construction])

    respond_to do |format|
      if @construction.save
        format.html { redirect_to @construction, notice: 'Construction was successfully created.' }
        format.json { render json: @construction, status: :created, location: @construction }
      else
        format.html { render action: "new" }
        format.json { render json: @construction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /constructions/1
  # PUT /constructions/1.json
  def update
    @construction = Construction.find(params[:id])

    respond_to do |format|
      if @construction.update_attributes(params[:construction])
        format.html { redirect_to @construction, notice: 'Construction was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @construction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /constructions/1
  # DELETE /constructions/1.json
  def destroy
    @construction = Construction.find(params[:id])
    @construction.destroy

    respond_to do |format|
      format.html { redirect_to constructions_url }
      format.json { head :no_content }
    end
  end
end
