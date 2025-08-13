# add_biru_schema.rb
# app/models 以下の ActiveRecord モデルに self.table_name を追加
# 既に self.table_name がある場合はスキップ

require 'active_support/inflector'

MODELS_DIR = Rails.root.join('app', 'models')

Dir.glob("#{MODELS_DIR}/**/*.rb").each do |file|
  text = File.read(file)

  # モデルクラスっぽい定義がない or 既に self.table_name がある場合はスキップ
  next unless text.match?(/class\s+\w+\s+<\s+ActiveRecord::Base/i)
  next if text.match?(/self\.table_name/)

  # クラス名からテーブル名を推測（複数形＋スネークケース）
  class_name = text.match(/class\s+(\w+)/)[1]
  table_name = class_name.underscore.pluralize

  # self.table_name を class の直後に挿入
  new_text = text.sub(/(class\s+\w+\s+<\s+ActiveRecord::Base\s*\n)/, "\\1  self.table_name = 'biru.#{table_name}'\n")

  File.write(file, new_text)
  puts "Updated #{file} -> biru.#{table_name}"
end
