# -*- encoding:utf-8 *-*
require "date"

class PerformanceMonthlyController < ApplicationController
  before_action :init

  def index
  end

  # 月次情報
  def display
    # 戻り値のHashを格納する為の配列
    @result_arr = []
    @graph_name = params[:graph_name]

    #################
    # 年度指定
    #################
    #    yyyy = params[:yyyymm].to_i
    #    yyyymm_s = yyyy.to_s + "04"
    #    yyyymm_e = (yyyy+1).to_s + "03"

    title = params[:yyyymm_title]

    if params[:yyyymm_type] == "0"
      # 年度指定
      yyyymm_s = params[:yyyymm_s]
      yyyymm_e = params[:yyyymm_e]
      @yyyymm_pick = false
    else
      # 月個別指定
      yyyymm_s = params[:yyyymm_s_monthly].gsub("/", "")
      yyyymm_e = params[:yyyymm_e_monthly].gsub("/", "")
      @yyyymm_pick = true
    end

    @yyyymm_s_monthly = params[:yyyymm_s_monthly]
    @yyyymm_e_monthly = params[:yyyymm_e_monthly]


    #################
    # 項目指定
    #################
    #  項目CDの先頭には２文字、ID重複しないためのキーが入っているので、それを除いて使用
    item_code = params[:item].slice(2, params[:item].length - 2)

    # params[:item_summary]    ←集計種別  1:合計 2:平均 3:最大
    item_summary = params[:item_summary]
    @item_calc = params[:item_calc]

    #################
    # 部署判定
    #################
    @plan_exists = false
    @prev_result_exists = false


    # ここで指定した条件で以下のkeyを持つ配列が返ってくるので、それを配列に格納
    # Hashのkey
    #
    # result['dept_name']　・・・　部署名
    # result['categories'] ・・・・　年月のカテゴリ配列
    #
    # result['this_year_plans'] 　・・・・　計画値の配列
    # result['this_year_results'] ・・・・　実績値の配列
    # result['prev_year_results'] ・・・・　前年実績値の配列
    #
    # result['cumulative_this_year_plans']　・・・計画値の累積
    # result['cumulative_this_year_results']　・・・実績値の累積
    # result['cumulative_prev_year_results']　・・・前年実績値の累積
    #
    # result['graph_plan'] ・・・・　計画／実績／前年実績の棒グラフ
    # result['graph_years'] ・・・・ 年計グラフ
    #
    # result['plan_exists']・・・・・・ 計画存在チェック
    # result['prev_result_exists']・ ・前年存在チェック

    #################################
    # 親部署処理
    #################################
    result = get_monthly_graph(params[:dept], yyyymm_s, yyyymm_e, item_code, item_summary, title)
    @result_arr.push(result)

    # 1件でも計画がある場合、計画有りと判定する
    @plan_exists = true if result["plan_exists"]
    @prev_result_exists = true if result["prev_result_exists"]

    @item_name = "不明"
    @item_name = result["item_name"] if result["item_name"]

    ##############################################
    # 指定された部署を折れ線グラフで表示する。(親部署処理)
    ##############################################
    @parent_result = LazyHighCharts::HighChart.new("graph") do |f|
      f.title(text: @graph_name.to_s + "の" + @item_name + "の実績一覧")
      strTmp = get_scale_calc
      f.yAxis(labels: { formatter: "function() {#{strTmp}}".js_code }, title: { text: "" })

      if @result_arr[0]["categories"].length <= 12
        f.xAxis(categories: @result_arr[0]["categories"].collect do |ym| ym.slice(4..5).to_i.to_s + "月" end, tickInterval: 1) # 1とかは列の間隔の指定
        # f.series(name: '実績', data: this_year_results, type: "spline")
      else
        interval = @result_arr[0]["categories"].length / 12
        f.xAxis(categories: @result_arr[0]["categories"].collect do |ym| ym.slice(0..3) + "/" + ym.slice(4..5) end, tickInterval: interval) # 1とかは列の間隔の指定
      end

      # 凡例
      f.legend(
          layout: "vertical",
          backgroundColor: "#FFFFFF",
          floating: true,
          align: "left",
          x: 250,
          verticalAlign: "top",
          y: 40
      )

      @result_arr.each_with_index do |result, i|
          f.series(name: result["dept_name"], data: result["this_year_results"].dup, type: "line")
      end
    end



    #################################
    # 子部署用ループ
    #################################
    children_arr = []
    @item_name = "不明"
    params[:dept_list].split(",").each do |busyo|
      result = get_monthly_graph(busyo, yyyymm_s, yyyymm_e, item_code, item_summary, title)
      children_arr.push(result)

      # 1件でも計画がある場合、計画有りと判定する
      @plan_exists = true if result["plan_exists"]
      @prev_result_exists = true if result["prev_result_exists"]

      @item_name = result["item_name"] if result["item_name"]
    end

    ##############################################
    # 指定された部署を折れ線グラフで表示する。(子部署用)
    ##############################################
    if children_arr.length > 0

      @group_result = LazyHighCharts::HighChart.new("graph") do |f|
        f.title(text: @graph_name.to_s + "の" + @item_name + "の実績一覧")
        strTmp = get_scale_calc
        f.yAxis(labels: { formatter: "function() {#{strTmp}}".js_code }, title: { text: "" })

        if children_arr[0]["categories"].length <= 12
          f.xAxis(categories: children_arr[0]["categories"].collect do |ym| ym.slice(4..5).to_i.to_s + "月" end, tickInterval: 1) # 1とかは列の間隔の指定
          # f.series(name: '実績', data: this_year_results, type: "spline")
        else
          interval = children_arr[0]["categories"].length / 12
          f.xAxis(categories: children_arr[0]["categories"].collect do |ym| ym.slice(0..3) + "/" + ym.slice(4..5) end, tickInterval: interval) # 1とかは列の間隔の指定
        end

        # 凡例
        f.legend(
            layout: "vertical",
            backgroundColor: "#FFFFFF",
            floating: true,
            align: "left",
            x: 250,
            verticalAlign: "top",
            y: 40
        )

        children_arr.each_with_index do |result, i|
            f.series(name: result["dept_name"], data: result["this_year_results"].dup, type: "line")
        end
      end
    end

    #################################
    # @result_arrに子部署を統合
    #################################
    children_arr.each do |child|
      @result_arr.push(child)
    end
  end


private
  def init
    @vacant_yyyymm_before = Date.today.prev_month.strftime("%Y/%m")
    @vacant_yyyymm_current = Date.today.strftime("%Y/%m")

    @yyyymm_s_monthly = Date.today.ago(11.month).strftime("%Y/%m")
    @yyyymm_e_monthly = Date.today.strftime("%Y/%m")


    @lease_month = 60
    @lease_kaiyaku = false

    # @yyyymm_pick = false
    @yyyymm_pick = true
  end

  # 指定された部署／項目／年月のグラフを取得する
  def get_monthly_graph(dept_id, yyyymm_from, yyyymm_to, item_code, item_summary, graph_title)
    dept_name = ""
    item_name = ""

    ##################################
    # 今年度の計画／実績と、昨年の実績を取得
    ##################################
    result = {}
    result["plan_exists"] = false
    result["prev_result_exists"] = false

    result["categories"] = []

    # 通常棒グラフ
    result["this_year_plans"] = []
    result["this_year_results"] = []
    result["prev_year_results"] = []

    # 積み上げ棒グラフ
    result["cumulative_this_year_plans"] = []
    result["cumulative_this_year_results"] = []
    result["cumulative_prev_year_results"] = []

    # 計画比／前年比
    result["comparison_plan"] = []
    result["comparison_result"] = []

    cummulative_this_plans = 0
    cumulative_this_year = 0
    cumulative_prev_year = 0

    case item_summary.to_i
    when 1
      func_summary = "SUM"
    when 2
      func_summary = "AVG"
    when 3
      func_summary = "SUM" # だたしこの時は年計は出さない
    end

    sql = ""
    sql = sql + "SELECT "
    sql = sql + " 年月 AS yyyymm "
    sql = sql + ",部署名 AS dept_name "
    sql = sql + ",項目名 AS item_name"
    sql = sql + "," + func_summary + "(計画) AS plan_value "
    sql = sql + "," + func_summary + "(実績) AS result_value "
    sql = sql + "FROM BIRU31.biru.T_月次情報 月次 "
    sql = sql + "INNER JOIN BIRU31.biru.M_部署 部署 ON 月次.部署ID = 部署.部署ID "
    sql = sql + "INNER JOIN BIRU31.biru.M_項目 項目 ON 月次.項目コード = 項目.項目コード "
    sql = sql + "WHERE 月次.部署ID = " + dept_id + " "
    sql = sql + "  AND 月次.項目コード = '" + item_code + "' "
    sql = sql + "  AND 月次.年月 BETWEEN '" + yyyymm_from + "' AND '" + yyyymm_to + "' "
    sql = sql + "GROUP BY 年月, 項目名, 部署名 "

    ##################################
    # 目盛で使う計算式を定義
    ##################################

    dt_from = Date.parse(yyyymm_from + "01") # 開始付
    adjustment_flg = false # 開始月調整フラグ
    ActiveRecord::Base.connection.select_all(sql).each do |rec|
        result["dept_name"] = rec["dept_name"]
        result["item_name"] = rec["item_name"]
        dept_name = rec["dept_name"]
        item_name = rec["item_name"]

        # 2018/07/28 add
        # 新規出店などで開始月より値が少ない場合の対応
        # 例えば201704～201803で集計する時、営業所が新規出店したのが201709とかだったりすると
        # その営業所だけ201804の数字が201709から始まる折れ線グラフができてしまう。
        while dt_from.strftime("%Y%m") < rec["yyyymm"] && adjustment_flg == false

          result["categories"].push(dt_from.strftime("%Y%m"))
          result["this_year_plans"].push(0)
          result["this_year_results"].push(0)
          result["comparison_plan"].push(0)
          result["cumulative_this_year_plans"].push(0)
          result["cumulative_this_year_results"].push(0)

          result["prev_year_results"].push(0)
          result["comparison_result"].push(0)
          result["cumulative_prev_year_results"].push(0)

          dt_from = dt_from >> 1 # 一か月進める。
        end
        adjustment_flg = true # 調整完了

        # 今年度の計画／実績
        result["categories"].push(rec["yyyymm"])
        result["this_year_plans"].push(rec["plan_value"].to_f)
        result["this_year_results"].push(rec["result_value"].to_f)
        result["comparison_plan"].push(BigDecimal("#{(rec['result_value'].to_f) / (rec['plan_value'].to_f) *100}").floor(1))

        # 積み上げ棒グラフ用
        cummulative_this_plans = cummulative_this_plans + rec["plan_value"].to_f
        cumulative_this_year = cumulative_this_year + rec["result_value"].to_f

        result["cumulative_this_year_plans"].push(cummulative_this_plans)
        result["cumulative_this_year_results"].push(cumulative_this_year)

        # 計画が一つでも登録されていれば、計画棒グラフを出す。
        result["plan_exists"] = true if rec["plan_value"].to_f > 0

        # 前年実績
        prev_year = rec["yyyymm"].slice(0..3).to_i - 1

        prev_sql = ""
        prev_sql = prev_sql + "SELECT "
        prev_sql = prev_sql + " " + func_summary + "(実績) AS result_value "
        prev_sql = prev_sql + "FROM BIRU31.biru.T_月次情報 "
        prev_sql = prev_sql + "WHERE 部署ID = " + dept_id + " "
        prev_sql = prev_sql + "  AND 項目コード = '" + item_code + "' "
        prev_sql = prev_sql + "  AND 年月 = '" + prev_year.to_s + rec["yyyymm"].slice(4..5) + "' "


        reg_flg = false
        ActiveRecord::Base.connection.select_all(prev_sql).each do |rec2|
            result["prev_year_results"].push(rec2["result_value"].to_f)
            result["comparison_result"].push(BigDecimal("#{((rec['result_value'].to_f))/(rec2['result_value'].to_f)*100}").floor(1))

            cumulative_prev_year = cumulative_prev_year + rec2["result_value"].to_f
            result["cumulative_prev_year_results"].push(cumulative_prev_year)

            result["prev_result_exists"] = true # 1件でも前年が存在すれば、前年有りと判定

            reg_flg = true
        end

        unless reg_flg
            result["prev_year_results"].push(0)
            result["comparison_result"].push(0)
            result["cumulative_prev_year_results"].push(cumulative_prev_year)
        end
    end

    # 目盛に使う数式を取得
    strTmp = get_scale_calc

    #######################################
    # 計画／実績／前年の棒グラフを作成
    #######################################
    result["graph_plan"] = LazyHighCharts::HighChart.new("graph") do |f|
      f.title(text: dept_name + "の" + item_name + "(" + graph_title + ")")
      f.yAxis(labels: { formatter: "function() {#{strTmp}}".js_code }, title: { text: "" })

      if result["categories"].length <= 12
        f.xAxis(categories: result["categories"].collect do |ym| ym.slice(4..5).to_i.to_s + "月" end, tickInterval: 1) # 1とかは列の間隔の指定
      else
        interval = result["categories"].length / 12
        f.xAxis(categories: result["categories"].collect do |ym| ym.slice(0..3) + "/" + ym.slice(4..5) end, tickInterval: interval) # 1とかは列の間隔の指定
      end

      # 凡例
      f.legend(
          layout: "vertical",
          reversed: true,
          backgroundColor: "#FFFFFF",
          floating: true,
          align: "right",
          x: -20,
          verticalAlign: "top",
          y: 250
      )

      if result["plan_exists"]
        f.series(name: "計画", data: result["this_year_plans"], type: "column", color: "#3276b1")
      end

      f.series(name: "実績", data: result["this_year_results"], type: "column", color: "#d9534f")
      f.series(name: "前年実績", data: result["prev_year_results"], type: "column", color: "#8cc63f")
    end

    #######################################
    # 計画／実績／前年の積算の折れ線グラフを作成
    #######################################
    result["graph_cumulative"] = LazyHighCharts::HighChart.new("graph") do |f|
      f.title(text: dept_name + "の" + item_name + "(" + graph_title + ")")
      f.yAxis(labels: { formatter: "function() {#{strTmp}}".js_code }, title: { text: "" })

      if result["categories"].length <= 12
        f.xAxis(categories: result["categories"].collect do |ym| ym.slice(4..5).to_i.to_s + "月" end, tickInterval: 1) # 1とかは列の間隔の指定
      else
        interval = result["categories"].length / 12
        f.xAxis(categories: result["categories"].collect do |ym| ym.slice(0..3) + "/" + ym.slice(4..5) end, tickInterval: interval) # 1とかは列の間隔の指定
      end

      # 凡例
      f.legend(
          layout: "vertical",
          reversed: true,
          backgroundColor: "#FFFFFF",
          floating: true,
          align: "left",
          x: 50,
          verticalAlign: "top",
          y: 40
      )

      if result["plan_exists"]
        f.series(name: "計画", data: result["cumulative_this_year_plans"], type: "line", color: "#3276b1")
      end
      f.series(name: "実績", data: result["cumulative_this_year_results"], type: "line", color: "#d9534f")
      f.series(name: "前年実績", data: result["cumulative_prev_year_results"], type: "line", color: "#8cc63f")
    end


    ############################################################################
    # 集計種別が「最大」でない時、年計グラフを作成（管理戸数の累計などだしても意味が無いから）
    # 集計種別が「最大」の時は月度ごとの棒グラフを作成
    ############################################################################
    # 指定した月で最小の月+12ヶ月を取得する。
    min_month = nil
    max_month = nil

    year_sum_sql = ""
    year_sum_sql = year_sum_sql + "SELECT "
    year_sum_sql = year_sum_sql + " MIN(年月) AS yyyymm_min "
    year_sum_sql = year_sum_sql + ",MAX(年月) AS yyyymm_max "
    year_sum_sql = year_sum_sql + "FROM BIRU31.biru.T_月次情報 "
    year_sum_sql = year_sum_sql + "WHERE 部署ID = " + dept_id + " "
    year_sum_sql = year_sum_sql + "  AND 項目コード = '" + item_code + "' "
    year_sum_sql = year_sum_sql + "  AND 実績 > 0 "
    year_sum_sql = year_sum_sql + "  AND 年月 < '300001' " # 受注残の月度は3000/01とかしているから

    ActiveRecord::Base.connection.select_all(year_sum_sql).each do |rec|
      min_month = rec["yyyymm_min"]
      max_month = rec["yyyymm_max"]
    end

    if min_month && max_month

      dt_start = Date.parse(min_month + "01") # 最小月
      dt_max = Date.parse(max_month + "01") # 最大月

      if item_summary.to_i != 3
        # 集計種別が「最大」でない時、年計グラフを作成（管理戸数の累計などだしても意味が無いから）

        dt_end = dt_start >> 11 # ＋11ヶ月後

        # データが12ヶ月以上ある場合、年計グラフを作成する
        if dt_end <= dt_max

          year_category = []
          year_result = []

          while dt_end <= dt_max

            year_category.push(dt_end.strftime("%Y%m"))

            year_sum_v2_sql = ""
            year_sum_v2_sql = year_sum_v2_sql + "SELECT "
            year_sum_v2_sql = year_sum_v2_sql + " " + func_summary + "(実績) AS result_value "
            year_sum_v2_sql = year_sum_v2_sql + "FROM BIRU31.biru.T_月次情報 "
            year_sum_v2_sql = year_sum_v2_sql + "WHERE 部署ID = " + dept_id + " "
            year_sum_v2_sql = year_sum_v2_sql + "  AND 項目コード = '" + item_code + "' "
            year_sum_v2_sql = year_sum_v2_sql + "  AND 年月 BETWEEN '" + dt_start.strftime("%Y%m") + "' AND '" + dt_end.strftime("%Y%m") + "' "

            ActiveRecord::Base.connection.select_all(year_sum_v2_sql).each do |rec|
                year_result.push({ history: "", y: rec["result_value"].to_f })
            end

            # 1ヶ月進める
            dt_start = dt_start >> 1
            dt_end = dt_end >> 1

          end

          interval = ((year_category.length)/12).to_i + 1

          result["graph_years"] = LazyHighCharts::HighChart.new("graph") do |f|
            f.title(text: dept_name + "の" + item_name + "の年計")
            f.xAxis(categories: year_category, tickInterval: interval) # 1とかは列の間隔の指定
            f.yAxis(labels: { formatter: "function() {#{strTmp}}".js_code }, title: { text: "" })
            f.series(name: "実績", data: year_result, type: "column")

            #           f.series(name: '実績',
            #             data: [
            #               {
            #                 name: 'Point 1',
            #                 color: '#00FF00',
            #                 y: 0
            #               },
            #               {
            #                 name: 'Point 2',
            #                 color: '#FF00FF',
            #                 y: 5
            #               }
            #             ], type: "column"
            #           )


            #            f.tooltip(formatter: 'function(){return this.series.data[1].name}'.js_code)
            #            f.tooltip(formatter: "function(){console.log(this);return '年月' + this.x + '<br/>' + this.point.history}".js_code)
            f.tooltip(formatter: "function(){return '年月 ' + this.x + '<br/>実績 ' + this.y }".js_code)
          end

        end

      else
        # 集計種別が「最大」の時は月度ごとの棒グラフを作成

        year_category = []
        year_result = []

        dt_current = dt_start

        while dt_current <= dt_max

          year_category.push(dt_current.strftime("%Y%m"))

          year_sum_v2_sql = ""
          year_sum_v2_sql = year_sum_v2_sql + "SELECT "
          year_sum_v2_sql = year_sum_v2_sql + " " + func_summary + "(実績) AS result_value "
          year_sum_v2_sql = year_sum_v2_sql + "FROM BIRU31.biru.T_月次情報 "
          year_sum_v2_sql = year_sum_v2_sql + "WHERE 部署ID = " + dept_id + " "
          year_sum_v2_sql = year_sum_v2_sql + "  AND 項目コード = '" + item_code + "' "
          year_sum_v2_sql = year_sum_v2_sql + "  AND 年月 = '" + dt_current.strftime("%Y%m") + "' "

          ActiveRecord::Base.connection.select_all(year_sum_v2_sql).each do |rec|
              year_result.push({ history: "", y: rec["result_value"].to_f })
          end

          # 1ヶ月進める
          dt_current = dt_current >> 1

        end

        interval = ((year_category.length)/12).to_i + 1

        result["graph_years"] = LazyHighCharts::HighChart.new("graph") do |f|
          f.title(text: dept_name + "の" + item_name + "の月度ごと実績")
          f.xAxis(categories: year_category, tickInterval: interval) # 1とかは列の間隔の指定
          f.yAxis(labels: { formatter: "function() {#{strTmp}}".js_code }, title: { text: "" })
          f.series(name: "実績", data: year_result, type: "column")
          f.tooltip(formatter: "function(){return '年月 ' + this.x + '<br/>実績 ' + this.y }".js_code)
        end

      end


    end

    result
  end

  # 数式を設定します
  def get_scale_calc
    strTmp = ""
    strTmp = strTmp + "if(this.value > 1000000){ return this.value / 1000000 + '百万' }"
    strTmp = strTmp + "else if(this.value > 1000000 ){return this.value / 10000 + '万' }"
    strTmp = strTmp + "else{return this.value }"
  end
end
