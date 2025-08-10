# test_tds.rb
require 'tiny_tds'
client = TinyTds::Client.new host: '192.168.0.12', port: 1433,
  username: 'biru', password: 'system9922', database: 'BIRU30'
puts client.execute("SELECT @@VERSION AS v").each.to_a
