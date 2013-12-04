require 'cases/helper'

class FileConverterTest < EagerDB::Test
  def setup
    @aggregator = EagerDB::ProcessorAggregator::AbstractProcessorAggregator.new
    @converter = EagerDB::FileConverter.new(@aggregator)
  end

  def test_basic_converter_file
    @converter.convert_file_processors(filepath("basic_conversion"))

    assert_equal 2, @aggregator.processors.length
    assert_equal 1, @aggregator.processors[0].preload_statements.length
    assert_equal 2, @aggregator.processors[1].preload_statements.length

    assert @aggregator.processors[0].matches?("SELECT * FROM users WHERE name = 'ryan'")
    assert @aggregator.processors[1].matches?("SELECT * FROM pinterest WHERE pin = 5 AND interest = 'balooga whales'")
  end

  def filepath(name)
    File.expand_path("../../converter_files/#{name}", __FILE__)
  end
end
