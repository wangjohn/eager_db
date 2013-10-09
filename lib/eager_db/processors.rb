module EagerDB
  module Processors
    extend ActiveSupport::Autoload
    extend ActiveSupport::Concern

    autoload :DefaultProcessor

    class ClassMethods
      def aggregate_processors(processors = [])
        processors = processors.uniq

        if processors.blank?
          processor_classes = [default_processor]
        else
          processor_classes = processors.collect do |name|
            find_processor(name)
          end
        end

        EagerDB::ProcessorAggregator.new(processor_classes)
      end

      def find_processor(processor)
        unless registered?(name)
          raise ArgumentError, "Attempting to find a processor with name '#{name}' which has not been defined."
        end

        return processor ? send(processor) : default_processor
      end

      def register_processor(name, processor)
        if registered?(name)
          raise ArgumentError, "Processor name '#{name}' already defined."
        end

        define_singleton_method(processor_name(name)) { processor }
      end

      private

        def registered?(name)
          return self.respond_to?(processor_name(name))
        end

        def processor_name(name)
          "#{name}_processor"
        end
    end

    register_processor(:default, Processors::DefaultProcessor)
  end
end
