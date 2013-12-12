require 'mysql2'

client = Mysql2::Client.new(:host => "localhost", :username => "root", :database => 'test')

def make_query(q, client)
  start = Time.now
  client.query(q)
  ending = Time.now
  puts ending - start
end

30.times do |i|
  make_query("SELECT * FROM user_profiles WHERE id = 3", client)
end
