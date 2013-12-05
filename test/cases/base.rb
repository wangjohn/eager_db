require 'cases/helper'

class BaseTest < EagerDB::Test
  class TestResque
    def enqueue(job_type, job)
      job_type.perform(job)
    end
  end

  def test_communication_channel_created
    history = []
    db_proc = Proc.new { |sql| history << sql }
    channel = EagerDB::Base.create_channel(db_proc)

    assert channel.is_a?(EagerDB::CommunicationChannel)
  end

  def test_communication_channel_can_use_processor_file
    history = []
    db_proc = Proc.new { |sql| history << sql }
    options = {
      processor_file: File.expand_path("../../converter_files/basic_conversion", __FILE__),
      resque: TestResque.new
    }
    channel = EagerDB::Base.create_channel(db_proc, options)

    channel.process_sql("SELECT * FROM users WHERE name = 'ryan'", { id: '12345' })

    assert_equal 1, history.length
    assert_equal ["SELECT * FROM products WHERE owner_id = 12345"], history.flatten
  end
end
