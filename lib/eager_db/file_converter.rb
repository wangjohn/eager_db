module EagerDB
  class FileConverterError < StandardError
  end

  class FileConverter
    attr_reader :processor_aggregator

    PROCESSOR_REGEX = /^\s*-/
    PRELOAD_REGEX = /^\s*=>/

    def initialize(processor_aggregator)
      @processor_aggregator = processor_aggregator
    end

    def convert_file_processors(filename)
      file = open_file(filename)

      processors = []
      counter = 0
      while (line = file.gets)
        handle_line(line, processors, counter)
        counter = counter + 1
      end
      file.close

      processors.each do |p|
        processor_aggregator.add_processor(p)
      end
    end

    private

      def handle_line(line, processors, counter)
        if PROCESSOR_REGEX =~ line
          handle_processor(line, processors, counter)
        elsif PRELOAD_REGEX =~ line
          handle_preload(line, processors, counter)
        end
      end

      def handle_processor(line, processors, counter)
        match_statement = sql_statement(line)

        if match_statement
          processor = Processors::AbstractProcessor.new(match_statement)
          processors << processor
        else
          raise FileConverterError, "Parse error in line #{counter}: #{line}"
        end
      end

      def handle_preload(line, processors, counter)
        preload_sql = sql_statement(line)
        binds = []
        previous_processor = processors.last
        unless previous_processor
          raise FileConverterError, "Preload was defined before any match statement."
        end

        line.split(",").each_with_index do |bind_string, index|
          if index > 0
            binds << generate_bind_value(bind_string, previous_processor)
          end
        end

        previous_processor.preload(preload_sql, binds)
      end

      def generate_bind_value(bind_string, processor)
        method_chain = bind_string.strip.split(".")
        method_chain.inject(processor) do |result, method|
          if (method_match = /\(.*\)/.match(method))
            method_name = method.gsub(/\(.*\)/, "")
            method_arguments = method_match[0].split(",")

            result.send(method_name, *method_arguments)
          else
            result.send(method)
          end
        end
      end

      def sql_statement(line)
        match = /\"(.*)\"|'(.*)'/.match(line)
        match[1] || match[2]
      end

      def open_file(filename)
        if File.file?(filename)
          File.new(filename, 'r')
        else
          raise FileConverterError, "Filename specified is not a regular file or does not exist: #{filename}"
        end
      end
  end
end
