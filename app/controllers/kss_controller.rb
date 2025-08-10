#-*- encoding:utf-8 -*-
class KssController < ApplicationController
	def index
			
		@month = ""
		if params[:month]
			@month = params[:month]
		else
			@month = get_cur_month
		end

		dt_base = Date.parse(@month + '01', "YYYYMMDD").months_ago(5)

		@calender = []
		10.times{
			@calender.push([dt_base.strftime("%Y/%m"), dt_base.strftime("%Y%m") ])
			dt_base = dt_base.next_month
		}
			
		batch_list = []
		
		####################################
		# 集計関係
		####################################

		# メール反響
		batch_id = 22
		batch_name = 'メール反響'
		tmp = ActiveRecord::Base.connection.select_all(get_kss_sql(batch_id, @month)).first
		if tmp
			tmp["batch_name"] = batch_name
			batch_list.push(tmp) 
		else
			batch_list.push({"batch_cd"=>batch_id, "month"=>@month, "batch_name"=>batch_name, "start_datetime"=>"", "end_datetime"=>"", "exec_status"=>"未実行"}) 
		end

		# 来店反響
		batch_id = 20
		batch_name = '来店反響'
		tmp = ActiveRecord::Base.connection.select_all(get_kss_sql(batch_id, @month)).first
		if tmp
			tmp["batch_name"] = batch_name
			batch_list.push(tmp) 
		else
			batch_list.push({"batch_cd"=>batch_id, "month"=>@month, "batch_name"=>batch_name, "start_datetime"=>"", "end_datetime"=>"", "exec_status"=>"未実行"}) 
		end
		
		# 賃貸契約
		batch_id = 21
		batch_name = '賃貸契約'
		tmp = ActiveRecord::Base.connection.select_all(get_kss_sql(batch_id, @month)).first
		if tmp
			tmp["batch_name"] = batch_name
			batch_list.push(tmp) 
		else
			batch_list.push({"batch_cd"=>batch_id, "month"=>@month, "batch_name"=>batch_name, "start_datetime"=>"", "end_datetime"=>"", "exec_status"=>"未実行"}) 
		end

		# 管理
		batch_id = 10
		batch_name = '管理物件'
		tmp = ActiveRecord::Base.connection.select_all(get_kss_sql(batch_id, @month)).first
		if tmp
			tmp["batch_name"] = batch_name
			batch_list.push(tmp) 
		else
			batch_list.push({"batch_cd"=>batch_id, "month"=>@month, "batch_name"=>batch_name, "start_datetime"=>"", "end_datetime"=>"", "exec_status"=>"未実行"}) 
		end
		
		# 工事
		batch_id = 30
		batch_name = '工事売上'
		tmp = ActiveRecord::Base.connection.select_all(get_kss_sql(batch_id, @month)).first
		if tmp
			tmp["batch_name"] = batch_name
			batch_list.push(tmp) 
		else
			batch_list.push({"batch_cd"=>batch_id, "month"=>@month, "batch_name"=>batch_name, "start_datetime"=>"", "end_datetime"=>"", "exec_status"=>"未実行"}) 
		end
		

		# 受託支援
		batch_id = 35
		batch_name = '受託支援システム 集計'
		#tmp = ActiveRecord::Base.connection.select_all(get_kss_sql(batch_id, @month)).first

		data_update = TrustAttackMonthReportUpdateHistory.find_by_month(@month)

		starttime = ''
		endtime = ''

		if data_update

			starttime = data_update.start_datetime.strftime("%Y/%m/%d %H:%M:%S")  if data_update.start_datetime
			endtime = data_update.update_datetime.strftime("%Y/%m/%d %H:%M:%S")  if data_update.update_datetime
	
			batch_list.push({"batch_cd"=>batch_id, "month"=>@month, "batch_name"=>batch_name, "start_datetime"=>starttime, "end_datetime"=>endtime, "exec_status"=>"完了"}) 
		else
			batch_list.push({"batch_cd"=>batch_id, "month"=>@month, "batch_name"=>batch_name, "start_datetime"=>"", "end_datetime"=>"", "exec_status"=>"未実行"}) 
		end

		# 入居者ポイント
		batch_id = 40
		batch_name = '入居者ポイント'
		tmp = ActiveRecord::Base.connection.select_all(get_kss_sql(batch_id, @month)).first
		if tmp
			tmp["batch_name"] = batch_name
			batch_list.push(tmp) 
		else
			batch_list.push({"batch_cd"=>batch_id, "month"=>@month, "batch_name"=>batch_name, "start_datetime"=>"", "end_datetime"=>"", "exec_status"=>"未実行"}) 
		end

		####################################
		# チェック関係
		####################################
		# チェック 契約入力

		batch_id = 50
		batch_name = '登録状況チェック'
		tmp = ActiveRecord::Base.connection.select_all(get_kss_sql(batch_id, '300001')).first
		if tmp
			tmp["batch_name"] = batch_name
			batch_list.push(tmp) 
		else
			batch_list.push({"batch_cd"=>batch_id, "month"=>'300001', "batch_name"=>batch_name, "start_datetime"=>"", "end_datetime"=>"", "exec_status"=>"未実行"}) 
		end

		# batch_id = 51
		# batch_name = '[チェック] 契約入力'
		# tmp = ActiveRecord::Base.connection.select_all(get_kss_sql(batch_id, '300001')).first
		# if tmp
		# 	tmp["batch_name"] = batch_name
		# 	batch_list.push(tmp) 
		# else
		# 	batch_list.push({"batch_cd"=>batch_id, "month"=>'300001', "batch_name"=>batch_name, "start_datetime"=>"", "end_datetime"=>"", "exec_status"=>"未実行"}) 
		# end

		# # チェック 他社契約入力
		# batch_id = 52
		# batch_name = '[チェック] 他社契約入力'
		# tmp = ActiveRecord::Base.connection.select_all(get_kss_sql(batch_id, '300001')).first
		# if tmp
		# 	tmp["batch_name"] = batch_name
		# 	batch_list.push(tmp) 
		# else
		# 	batch_list.push({"batch_cd"=>batch_id, "month"=>'300001', "batch_name"=>batch_name, "start_datetime"=>"", "end_datetime"=>"", "exec_status"=>"未実行"}) 
		# end

		# # チェック 解約入力
		# batch_id = 53
		# batch_name = '[チェック] 解約入力'
		# tmp = ActiveRecord::Base.connection.select_all(get_kss_sql(batch_id, '300001')).first
		# if tmp
		# 	tmp["batch_name"] = batch_name
		# 	batch_list.push(tmp) 
		# else
		# 	batch_list.push({"batch_cd"=>batch_id, "month"=>'300001', "batch_name"=>batch_name, "start_datetime"=>"", "end_datetime"=>"", "exec_status"=>"未実行"}) 
		# end

		gon.data_list = batch_list

	end


	##########################################################################################################
	# 2018/05/20 ※config/routes.rbにも定義を追加することを忘れずに。ここにいれないとparams[:month]が正しく取れない
	##########################################################################################################

	# 来店バッチを実行
	def exec_raiten
			
		# ストアドプロシージャを実行
		month = params[:month]
		@rtns = ActiveRecord::Base.execute_procedure "BIRU31.biru.P_取込_募集_来店反響", nch月度:month , dt開始日:get_month_day_start(month), dt終了日:get_month_day_end(month)
		
		# 結果を表示
		redirect_to :action=>'index'
	end

	# 賃貸契約バッチを実行
	def exec_chintai
			
		# ストアドプロシージャを実行
		month = params[:month]
		
		# 受注残
		@rtns = ActiveRecord::Base.execute_procedure "BIRU31.biru.P_取込_募集_賃貸契約", nch月度:'300001' , dt開始日:get_month_day_start(month), dt終了日:get_month_day_end(month)

		# 成約(ここでencodeエラーになるのは、ひょっとして部署Mに未定義の部署があったから？？2017/09/19）
		@rtns = ActiveRecord::Base.execute_procedure "BIRU31.biru.P_取込_募集_賃貸契約", nch月度:month , dt開始日:get_month_day_start(month), dt終了日:get_month_day_end(month)

		@rtns = ActiveRecord::Base.execute_procedure "BIRU31.biru.P_取込_募集_賃貸契約", nch月度:'400001' , dt開始日:get_month_day_start(month), dt終了日:get_month_day_end(month)
		@rtns = ActiveRecord::Base.execute_procedure "BIRU31.biru.P_取込_募集_賃貸契約", nch月度:'400002' , dt開始日:get_month_day_start(month), dt終了日:get_month_day_end(month)
		@rtns = ActiveRecord::Base.execute_procedure "BIRU31.biru.P_取込_募集_賃貸契約", nch月度:'400003' , dt開始日:get_month_day_start(month), dt終了日:get_month_day_end(month)
		@rtns = ActiveRecord::Base.execute_procedure "BIRU31.biru.P_取込_募集_賃貸契約", nch月度:'500001' , dt開始日:get_month_day_start(month), dt終了日:get_month_day_end(month)
		
		# 結果を表示
		redirect_to :action=>'index'
	end

	# メール反響バッチを実行 2018/05/20
	def exec_mail_reaction
			
		# ストアドプロシージャを実行
		month = params[:month]
		@rtns = ActiveRecord::Base.execute_procedure "BIRU31.biru.P_取込_募集_メール反響_月次反映", nch月度:month
		
		# 結果を表示
		redirect_to :action=>'index'
	end
	
	# 管理物件バッチを実行
	def exec_kanri_bukken
			
		month = params[:month]
		# ストアドプロシージャを実行
		@rtns = ActiveRecord::Base.execute_procedure "BIRU31.biru.P_取込_管理_物件一覧", nch月度: month
		
		# 結果を表示
		redirect_to :action=>'index'
	end
	
	# 工事売上バッチを実行
	def exec_kouji_uriage
			
		month = params[:month]
		# ストアドプロシージャを実行
		@rtns = ActiveRecord::Base.execute_procedure "BIRU31.biru.P_取込_工事情報", nch月度: month
		
		# 結果を表示
		redirect_to :action=>'index'
	end

	# 入居者ポイントバッチを実行
	def exec_nyuukyo_point
			
		month = params[:month]
		# ストアドプロシージャを実行
		@rtns = ActiveRecord::Base.execute_procedure "BIRU31.biru.P_取込_入居者ポイント", nch月度: month
		
		# 結果を表示
		redirect_to :action=>'index'
	end

	# チェック用バッチ（全て）を実行
	def exec_check_all
		month = params[:month]
		# ストアドプロシージャを実行
		@rtns = ActiveRecord::Base.execute_procedure "BIRU31.biru.P_CHECK_ALL"
		# 結果を表示
		redirect_to :action=>'index'
	end

	# 受託支援システムの集計レポートを作成
	def exec_trust_attack
			
		month = params[:month]

		# 登録開始日の保存
		@data_update = TrustAttackMonthReportUpdateHistory.find_or_create_by_month(month)
		@data_update.month = month
		@data_update.start_datetime = Time.now
		@data_update.save!
		
		# レポートの作成
		app_con = TrustManagementsController.new
		TrustManagementsController.get_trust_members.keys.each do |key|
			app_con.generate_report_info(month, BiruUser.find_by_code(key), TrustManagementsController.get_trust_members[key][:shop_name])
		end

		# 登録完了日を保存
		@data_update.update_datetime = Time.now
		@data_update.save!
		
		# 結果を表示
		redirect_to :action=>'index'
	end

private

		def get_kss_sql(batch_cd, month)
	    strSql = ""
	    
	    strSql = strSql + "SELECT  "
	    strSql = strSql + " A.取込バッチコード as batch_cd"
	    strSql = strSql + ",A.月度 as month "
	    strSql = strSql + ",A.取込バッチ名 as batch_name "
	    strSql = strSql + ",format(A.最新開始日時, 'yyyy/MM/dd HH:mm:ss') as start_datetime "
	    strSql = strSql + ",format(A.最新終了日時, 'yyyy/MM/dd HH:mm:ss') as end_datetime "
	    strSql = strSql + ",case A.実行ステータス when 1 then '実行中' when 2 then '完了' else '不明' end as exec_status "
	    strSql = strSql + "FROM BIRU31.biru.T_取込バッチ管理 A "
	    
	    #strSql = strSql + "INNER JOIN ( "
	    #strSql = strSql + "  SELECT  "
	    #strSql = strSql + "   取込バッチコード "
	    #strSql = strSql + "  ,MAX(月度) MAX月度 "
	    #strSql = strSql + "  FROM BIRU31.biru.T_取込バッチ管理 "
	    #strSql = strSql + "  WHERE 取込バッチコード = " + batch_cd.to_s
	    #strSql = strSql + "  GROUP BY 取込バッチコード"
	    #strSql = strSql + ") B ON A.取込バッチコード = B.取込バッチコード AND A.月度 = B.MAX月度 "
	    
	    strSql = strSql + "WHERE 月度 = '" + month + "' "
	    strSql = strSql + "  AND 取込バッチコード = " + batch_cd.to_s
		

	    
	    return strSql
	  end
end
