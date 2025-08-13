# -*- encoding :utf-8 -*-

class MailReaction < ActiveRecord::Base
  self.table_name = 'biru.mail_reactions'
  set_table_name 'BIRU31.biru.T_募集_メール反響'
  set_primary_key 'メール反響ID'

  validates '月度', length: { is: 6 }    # 「6文字固定」
  validates '月度', numericality: true   # 数値
  validates '受信日時', presence: true   # 必須

  validates '徒歩', numericality: true ,:allow_blank => true  # 数値(null許可)
  validates 'バス', numericality: true ,:allow_blank => true  # 数値(null許可)
  validates '名寄点数', numericality: true ,:allow_blank => true  # 数値(null許可)
  
  
end
