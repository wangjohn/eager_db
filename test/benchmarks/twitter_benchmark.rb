require './benchmark'
require 'mysql2'
require 'eager_db'

module Benchmark
  module TwitterBenchmark
    class GetFollowers < AbstractTransactionType
      def continuation_bind_values(previous_transaction, previous_binds, previous_result)
        if previous_transaction.is_a?(GetUserTweets)
          [random_row_attribute(previous_result, 'uid')]
        else
          random_bind_values
        end
      end

      def random_bind_values
        [rand(100)]
      end

      def non_binded_sql
        "SELECT f2 FROM followers WHERE f1 = ? LIMIT 20"
      end
    end

    class GetFollows < AbstractTransactionType
      def continuation_bind_values(previous_transaction, previous_binds, previous_result)
        if previous_transaction.is_a?(GetUserTweets)
          [random_row_attribute(previous_result, 'uid')]
        else
          random_bind_values
        end
      end

      def random_bind_values
        [rand(100)]
      end

      def non_binded_sql
        "SELECT f2 FROM follows WHERE f1 = ? LIMIT 20"
      end
    end

    class GetUserTweets < AbstractTransactionType
      def continuation_bind_values(previous_transaction, previous_binds, previous_result)
        if previous_transaction.is_a?(GetFollowers) || previous_transaction.is_a?(GetFollows)
          [random_row_attribute(previous_result, 'f2')]
        else
          random_bind_values
        end
      end

      def random_bind_values
        [rand(100)]
      end

      def non_binded_sql
        "SELECT * FROM tweets WHERE uid = ?"
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


NUM_USERS = 100
NUM_TWEETS = 50 * NUM_USERS
NUM_FOLLOWERS = 20 * NUM_USERS
NUM_FOLLOWS = 20 * NUM_USERS

def setup_twitter_database(client)
  setup = SetupDatabase.new(client)
  setup.create_table('user_profiles', ['id INT', "name CHAR(20)"])
  setup.create_table('follows', ['f1 INT', 'f2 INT'])
  setup.create_table('tweets', ['uid INT', 'name CHAR(20)'])
  setup.create_table('followers', ['f1 INT', 'f2 INT'])


  puts "Inserting Users into database"
  NUM_USERS.times do |t|
    puts "Inserted #{t} users" if t % 20 == 0
    setup.insert_record('user_profiles', [["id", t], ["name", t.to_s]])
  end

  puts "Inserting Tweets into database"
  NUM_TWEETS.times do |t|
    puts "Inserted #{t} tweets" if t % 20 == 0
    setup.insert_record('tweets', [['uid', t % NUM_USERS], ['name', t.to_s]])
  end

  puts "Inserting followers into database"
  NUM_FOLLOWERS.times do |t|
    puts "Inserted #{t} followers" if t % 20 == 0
    user1 = (rand * NUM_USERS).to_i
    user2 = (rand * NUM_USERS).to_i
    if (user1 != user2)
      setup.insert_record('followers', [['f1', user1], ['f2', user2]])
    end
  end

  puts "Inserting follows into database"
  NUM_FOLLOWS.times do |t|
    puts "Inserted #{t} follows" if t % 20 == 0
    user1 = (rand * NUM_USERS).to_i
    user2 = (rand * NUM_USERS).to_i
    if (user1 != user2)
      setup.insert_record('follows', [['f1', user1], ['f2', user2]])
    end
  end
end

class BasicQueue
  def enqueue(job_type, job)
    job_type.perform(job)
  end
end

def run_processor(latency_storage, channel_options)
  client = Mysql2::Client.new(:host => "localhost", :username => "root", :database => 'test')
  db_proc = Proc.new { |q| client.query(q) }
  #channel = EagerDB::Base.create_channel(db_proc, channel_options)
  channel = nil

  get_followers = Benchmark::TwitterBenchmark::GetFollowers.new({})
  get_user_tweets = Benchmark::TwitterBenchmark::GetUserTweets.new({})
  get_follows = Benchmark::TwitterBenchmark::GetFollows.new({})

  get_user_tweets.add_child(get_followers, 0.3)
  get_user_tweets.add_child(get_follows, 0.3)
  get_follows.add_child(get_user_tweets, 0.3)
  get_followers.add_child(get_user_tweets, 0.3)

  transactions = {
    get_followers => 0.3,
    get_follows => 0.3,
    get_user_tweets => 0.4
  }

  process = Benchmark::MarkovProcess.new({
    transaction_types: transactions,
    connection: client,
    latency_storage: latency_storage
  })
  process.set_channel(channel)
  process.run(1000)
end

def threaded_run(channel_options, num_threads = 1)
  latency_storage = Benchmark::LatencyStorage.new

  puts "Starting simulations"
  threads = []
  num_threads.times do |i|
    puts "Starting thread #{i}"
    threads << Thread.new { run_processor(latency_storage, channel_options) }
  end
  threads.each do |t|
    t.join
  end

  puts "Finished simulations"
  latency_storage.average_latencies.each do |avg|
    p avg
  end
end

channel_options = {
  resque: BasicQueue.new,
  processor_file: File.expand_path("../twitter_benchmark_mp", __FILE__)
}

threaded_run(channel_options, 2)
