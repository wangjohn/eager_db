module EagerDB
  class FileConverter
    def initialize(processor_aggregator)
      @processor_aggregator = processor_aggregator
    end

    def convert_file_processors(filename)
      file = open_file(filename)

      processors = []
      counter = 0
      begin
        while (line = file.gets)
          handle_line(line, processors, counter)
          counter = counter + 1
        end
        file.close
      rescue => err
        puts "Exception in reading file: #{err}"
      end
    end

    private

      def handle_line(line, processors, counter)
        if /^\s*-/ =~ line
          handle_processor(line, processors, counter)
        elsif /^\s*=>/ =~ line
          handle_preload(line, processors, counter)
        end
      end

      def handle_processor(line, processors, counter)
        match_statement = sql_statement(line)

        if match_statement
          processor = Processors::AbstractProcessor.new(match_statement)
          processors < processor
        else
          raise ArgumentError, "Parse error in line #{counter}: #{line}"
        end
      end

      def handle_preload(line, processors, counter)
        preload_sql = sql_statement(line)
        binds = []
      end

      def sql_statement(line)
        match = /\"(.*)\"|'(.*)'/.match(line)
        match[1] || match[2]
      end

      def open_file(filename)
        if File.file?(filename)
          File.new(filename, 'r')
        else
          raise ArgumentError, "Filename specified is not a regular file or does not exist."
        end
      end
  end
end
