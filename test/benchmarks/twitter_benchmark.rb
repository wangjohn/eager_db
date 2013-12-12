require './benchmark'
require 'mysql2'

module Benchmark
  module TwitterBenchmark
    class GetFollowers < AbstractTransactionType
      def continuation_bind_values(previous_transaction, previous_binds, previous_result)
        if previous_transaction.is_a?(GetUserTweets)
          [previous_result.id]
        else
          random_bind_values
        end
      end

      def random_bind_values
        [(rand * 1000).to_i]
      end

      def non_binded_sql
        "SELECT f2 FROM followers WHERE f1 = ? LIMIT 20"
      end
    end
  end
end

class SetupDatabase
  attr_reader :connection

  def initialize(connection)
    @connection = connection
  end

  def create_table(name, attributes)
    sql = "CREATE TABLE #{name} ("
    sql += attributes.collect { |attr| attr }.join(",")
    sql += ")"

    connection.query("DROP TABLE IF EXISTS #{name}")
    connection.query(sql)
  end

  def insert_record(table, name_val_pairs)

    insert = "INSERT INTO #{table} ("
    insert += name_val_pairs.collect { |pair| pair[0] }.join(",")
    insert += ")"

    values = "VALUES ("
    values += name_val_pairs.collect { |pair| pair[1] }.join(",")
    values += ")"

    sql = insert + "\n" + values
    connection.query(sql)
  end
end

client = Mysql2::Client.new(:host => "localhost", :username => "root", :database => 'test')

setup = SetupDatabase.new(client)
setup.create_table('user_profiles', ['id INT', "name CHAR(20)"])
setup.create_table('follows', ['f1 INT', 'f2 INT'])
setup.create_table('tweets', ['uid INT', 'name CHAR(20)'])
setup.create_table('followers', ['f1 INT', 'f2 INT'])

NUM_USERS = 100
NUM_TWEETS = 50 * NUM_USERS
NUM_FOLLOWERS = 20 * NUM_USERS
NUM_FOLLOWS = 20 * NUM_USERS

puts "Inserting Users into database"
NUM_USERS.times do |t|
  setup.insert_record('user_profiles', [["id", t], ["name", t.to_s]])
end

puts "Inserting Tweets into database"
NUM_TWEETS.times do |t|
  setup.insert_record('tweets', [['uid', t % NUM_USERS], ['name', t.to_s]])
end

puts "Inserting followers into database"
NUM_FOLLOWERS.times do |t|
  user1 = (rand * NUM_USERS).to_i
  user2 = (rand * NUM_USERS).to_i
  if (user1 != user2)
    setup.insert_record('followers', [['f1', user1], ['f2', user2]])
  end
end

puts "Inserting follows into database"
NUM_FOLLOWS.times do |t|
  user1 = (rand * NUM_USERS).to_i
  user2 = (rand * NUM_USERS).to_i
  if (user1 != user2)
    setup.insert_record('follows', [['f1', user1], ['f2', user2]])
  end
end

rs = client.query("SELECT * FROM user_profiles WHERE name = '14'")
rs.each do |row|
  p row
end
