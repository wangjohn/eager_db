require 'pg'
require 'resque'
require 'eager_db'

class PGconnWrapper
  def initialize(pgconn, channel)
    @pgconn = pgconn
    @channel = channel
  end

  def exec(sql)
    result = super
    channel.process_sql(sql, result)
    result
  end
end

# Setup for EagerDB.
#
# The database proc should go ahead and execute the sql queries that come from
# EagerDB for preloading.
#
# We can also specify a file to read manual preloads from.
database_proc = Proc.new { |sql| conn.exec(sql) }
options = {
  processor_file: File.expand_path("../../test/converter_files/basic_conversion", __FILE__),
  resque: Resque
}

channel = EagerDB::Base.create_channel(database_proc, options)

# Connect to the PostgreSQL database
conn = PGconn.open(:dbname => 'test')
wrapper = PgconnWrapper.new(conn, channel)

result = wrapper.exec("SELECT * FROM users WHERE name = 'john'")
sleep(1)
wrapper.exec("SELECT * FROM products WHERE owner_id = 1")
