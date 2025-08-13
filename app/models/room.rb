# -*- encoding :utf-8 -*-

class Room < ActiveRecord::Base

  self.table_name = 'biru.rooms'
  # デフォルトスコープを定義
  default_scope { where(delete_flg: false) }

  belongs_to :building
  belongs_to :room_type
  belongs_to :room_layout
  belongs_to :trust
  belongs_to :manage_type
  belongs_to :renters_room
  belongs_to :room_status


  def get_manage_date

    sql = ""
    sql = sql + "SELECT "
    sql = sql + " 管理開始日 as start_day "
    sql = sql + ",管理終了日 as end_day "
    sql = sql + " FROM BIRU31.biru.T_管理_物件一覧 物件 "
    sql = sql + " WHERE 管理委託契約CD = " + trust.code + " "
    sql = sql + "   AND 部屋名 = '" + name + "' "
    sql = sql + "   AND 月度 = (SELECT MAX(月度) FROM BIRU31.biru.T_管理_物件一覧); "
    
    result = []

    self.connection.select_all(sql).each do |rec|
      result.push(rec['start_day'])
      result.push(rec['end_day'])
    end
    return result
  end


end
