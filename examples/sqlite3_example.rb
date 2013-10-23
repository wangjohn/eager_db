require 'sqlite3'
require 'eager_db'

### Subclass the SQLite3::Database class
class SQLite3EagerDB < SQLite3::Database
  include EagerDB
end

# Open a database
db = SQLite3EagerDB.new "test.db"

# Create a database
rows = db.execute <<-SQL
  create table if not exists numbers(
    name varchar(30),
    val int
  );
SQL

# Execute a few inserts
{
  "one" => 1,
  "two" => 2,
}.each do |pair|
  db.execute "insert into numbers values ( ?, ? )", pair
end

# Find a few rows
db.execute( "select * from numbers" ) do |row|
  p row
end
