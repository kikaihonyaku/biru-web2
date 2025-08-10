# -*- encoding:utf-8 *-*
require "date"

class PerformanceBuildAgeController < ApplicationController
  before_action :init

  def index
  end

  def display
    @yyyymm_s_monthly = params[:yyyymm_s_monthly]
    yyyymm_s = params[:yyyymm_s_monthly].gsub("/", "")


    # 部署IDから部署リストを取得
    dept_list = []
    sql_depts = ""
    sql_depts += "SELECT * "
    sql_depts += "FROM BIRU31.biru.F_部署一覧取得(" + params[:dept] + ") "
    ActiveRecord::Base.connection.select_all(sql_depts).each do |rec|
      dept_list.push(rec["v値"])
    end


    sql_base = ""
    sql_base += "FROM BIRU31.biru.Fn_管理戸数_対象物件('" + yyyymm_s + "', 1) 物件 "
    sql_base += "INNER JOIN BIRU31.biru.M_部署 部署 ON 物件.管理店舗CD = 部署.変換用営業所CD  "
    sql_base += "WHERE 部署.部署ID IN ( " + dept_list.join(",") + " ) "


    #######################################################
    # 営業所別の築年数を出す(棟数別)(物件種別ごとの積み上げグラフ)
    #######################################################
    # 築年数の最小と最大を取得(棟数別)
    min_age = nil
    max_age = nil

    sql_minmax = ""
    sql_minmax += "SELECT MIN(建物_築年数) as min_age, MAX(建物_築年数) AS max_age "
    sql_minmax += sql_base
    sql_minmax += "AND 建物_築年数 < 100 "
    ActiveRecord::Base.connection.select_all(sql_minmax).each do |rec|
      min_age = rec["min_age"]
      max_age = rec["max_age"]
    end

    unless max_age
      min_age = 0
      max_age = 0
    end

    @category_arr = []
    @biru_age_aprt = [] # アパート
    @biru_age_mnsn = [] # マンション
    @biru_age_bmmn = [] # 分譲マンション
    @biru_age_kodt = [] # 戸建て
    @biru_age_etc = []  # その他

    @biru_age_aprt_room = [] # アパート
    @biru_age_mnsn_room = [] # マンション
    @biru_age_bmmn_room = [] # 分譲マンション
    @biru_age_kodt_room = [] # 戸建て
    @biru_age_etc_room = []  # その他


    while min_age <= max_age

      @category_arr.push(min_age)

      #########################################################
      # 棟数
      #########################################################
      aprt_cnt = 0
      mnsn_cnt = 0
      bnmn_cnt = 0
      kodt_cnt = 0
      etc_cnt = 0

      sql_cnt = "SELECT COUNT(*) as cnt, 部屋種別CD "
      sql_cnt += "FROM (  "
      sql_cnt += "SELECT 物件CD, 部屋種別CD  "
      sql_cnt += sql_base
      sql_cnt += "AND 建物_築年数 = " + min_age.to_s + " "
      sql_cnt += "GROUP BY 物件CD, 部屋種別CD "
      sql_cnt += ") X GROUP BY 部屋種別CD  "

      ActiveRecord::Base.connection.select_all(sql_cnt).each do |rec|
        case rec["部屋種別CD"]
        when 10
          # アパート
          aprt_cnt = aprt_cnt + rec["cnt"]

        when 20
          # マンション
          mnsn_cnt = mnsn_cnt + rec["cnt"]

        when 15
          # 分譲マンション
          bnmn_cnt = bnmn_cnt + rec["cnt"]

        when 25
          # 戸建て
          kodt_cnt = kodt_cnt + rec["cnt"]

        else
          # それ以外のもの
          etc_cnt = etc_cnt + rec["cnt"]
        end
      end

      @biru_age_aprt.push(aprt_cnt)
      @biru_age_mnsn.push(mnsn_cnt)
      @biru_age_bmmn.push(bnmn_cnt)
      @biru_age_kodt.push(kodt_cnt)
      @biru_age_etc.push(etc_cnt)


      #########################################################
      # 部屋別
      #########################################################
      aprt_cnt_room = 0
      mnsn_cnt_room = 0
      bnmn_cnt_room = 0
      kodt_cnt_room = 0
      etc_cnt_room = 0

      sql_cnt = ""
      sql_cnt += "SELECT COUNT(部屋名) as cnt_room, 部屋種別CD  "
      sql_cnt += sql_base
      sql_cnt += "AND 建物_築年数 = " + min_age.to_s + " "
      sql_cnt += "GROUP BY 物件CD, 部屋名, 部屋種別CD "

      ActiveRecord::Base.connection.select_all(sql_cnt).each do |rec|
        case rec["部屋種別CD"]
        when 10
          # アパート・マンション
          aprt_cnt_room = aprt_cnt_room + rec["cnt_room"]

        when 20
          # マンション
          mnsn_cnt_room = mnsn_cnt_room + rec["cnt_room"]

        when 15
          # 分譲マンション
          bnmn_cnt_room = bnmn_cnt_room + rec["cnt_room"]

        when 25
          # 戸建て
          kodt_cnt_room = kodt_cnt_room + rec["cnt_room"]

        else
          # それ以外のもの
          etc_cnt_room = etc_cnt_room + rec["cnt_room"]
        end
      end

      @biru_age_aprt_room.push(aprt_cnt_room)
      @biru_age_mnsn_room.push(mnsn_cnt_room)
      @biru_age_bmmn_room.push(bnmn_cnt_room)
      @biru_age_kodt_room.push(kodt_cnt_room)
      @biru_age_etc_room.push(etc_cnt_room)

      min_age = min_age + 1
    end

    # 棟数別
    @build_sum = LazyHighCharts::HighChart.new("graph") do |f|
      f.chart(
        renderTo: "container",
        type: "column"
      )

      # 凡例
      f.legend(
          layout: "vertical",
          reversed: true,
          backgroundColor: "#FFFFFF",
          floating: true,
          align: "right",
          x: -20,
          verticalAlign: "top",
          y: 100
      )

      f.title(text: params[:graph_name] + "の築年数(棟数別)")
      f.xAxis(categories: @category_arr, tickInterval: 2) # 1とかは列の間隔の指定
      f.series(name: "その他", data: @biru_age_etc, type: "column")
      f.series(name: "戸建て", data: @biru_age_kodt, type: "column")
      f.series(name: "分譲Ｍ", data: @biru_age_bmmn, type: "column")
      f.series(name: "マンション", data: @biru_age_mnsn, type: "column")
      f.series(name: "アパート", data: @biru_age_aprt, type: "column")
      f.plotOptions(
        column: { stacking: "normal",
            dataLabels: {
              enabled: false,
              color: "blue"|| "white" || "red"
            }
        }
      )
    end


    @room_sum = LazyHighCharts::HighChart.new("graph") do |f|
      f.chart(
        renderTo: "container",
        type: "column"
      )

      # 凡例
      f.legend(
          layout: "vertical",
          reversed: true,
          backgroundColor: "#FFFFFF",
          floating: true,
          align: "right",
          x: -20,
          verticalAlign: "top",
          y: 100
      )

      f.title(text: params[:graph_name] + "の築年数(戸数別)")
      f.xAxis(categories: @category_arr, tickInterval: 2) # 1とかは列の間隔の指定
      f.series(name: "その他", data: @biru_age_etc_room, type: "column")
      f.series(name: "戸建て", data: @biru_age_kodt_room, type: "column")
      f.series(name: "分譲Ｍ", data: @biru_age_bmmn_room, type: "column")
      f.series(name: "マンション", data: @biru_age_mnsn_room, type: "column")
      f.series(name: "アパート", data: @biru_age_aprt_room, type: "column")
      f.plotOptions(
        column: { stacking: "normal",
            dataLabels: {
              enabled: false,
              color: "blue"|| "white" || "red"
            }
        }
      )
    end

    ######################################
    # 内訳一覧を表示する。
    ######################################
    sql_内訳 = ""
    sql_内訳 += "SELECT 物件CD, 物件名, 管理店舗名, 部屋種別CD, 部屋種別名, 建物_築年数, 管理方式名, COUNT(部屋名) AS 部屋数 "
    sql_内訳 += sql_base
    sql_内訳 += "AND 建物_築年数 < 100 "
    sql_内訳 += "GROUP BY 物件CD, 物件名, 管理店舗名, 部屋種別CD, 部屋種別名, 建物_築年数, 管理方式名 "
    sql_内訳 += "ORDER BY 建物_築年数, 部屋種別CD "

    @biru_detail = []
    ActiveRecord::Base.connection.select_all(sql_内訳).each do |rec|
      @biru_detail.push(rec)
    end

    #################################################
    # 営業所別・築年数を出す(戸数別)(間取りの積み上げグラフ)
    #################################################

    # 戸数別


    # 戸数・間取り別

    # 戸数・部屋種別別
    #
    ###############################
    # 営業所別・間取り別の築年数を出す(戸数別)
    ###############################


    # @arr = manage_types
    @active_biru_age = ""
  end


private
  def init
    @yyyymm_s_monthly = Date.today.strftime("%Y/%m")
  end
end
