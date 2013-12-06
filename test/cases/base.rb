require 'cases/helper'

class TestResque
  def enqueue(job_type, job)
    job_type.perform(job)
  end
end

class BaseTest < EagerDB::Test
  def test_communication_channel_created
    history = []
    db_proc = Proc.new { |sql| history << sql }
    channel = EagerDB::Base.create_channel(db_proc)

    assert channel.is_a?(EagerDB::CommunicationChannel)
  end
end

class CommunicationChannelWithProcessorFileTest < EagerDB::Test
  def setup
    @history = []
    @db_proc = Proc.new { |sql| @history << sql }
    options = {
      processor_file: File.expand_path("../../converter_files/basic_conversion", __FILE__),
      resque: TestResque.new
    }
    @channel = EagerDB::Base.create_channel(@db_proc, options)
  end

  def test_matching_sql_with_single_preload
    @channel.process_sql("SELECT * FROM users WHERE name = 'ryan'", { id: '12345' })

    assert_equal 1, @history.length
    assert_equal ["SELECT * FROM products WHERE owner_id = 12345"], @history.flatten
  end

  def test_matching_sql_with_two_preloads
    @channel.process_sql("SELECT * FROM pinterest WHERE pin = 'rock' AND interest = 'music'", { id: '1337' })

    assert_equal 2, @history.flatten.length
    assert_equal "SELECT * FROM tables WHERE pin = 'rock' AND interest = 'music'", @history.flatten[0]
    assert_equal "SELECT * FROM interests WHERE interest = 'music' AND pinterest_id = 1337", @history.flatten[1]
  end

  def test_nonmatching_sql_does_not_preload_anything
    @channel.process_sql("SELECT * FROM blahblahblah WHERE superman = 'Dwayne Wade'", { id: '22', name: 'wayne' })

    assert_equal 0, @history.length
  end
end
