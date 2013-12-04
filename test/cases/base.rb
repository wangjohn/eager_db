require 'cases/helper'

class BaseTest < EagerDB::Test
  def test_communication_channel_created
    history = []
    db_proc = Proc.new { |sql| history << sql }
    channel = EagerDB::Base.create_channel(db_proc)

    assert channel.is_a?(EagerDB::CommunicationChannel)
  end
end
