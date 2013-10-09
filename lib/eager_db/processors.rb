module EagerDB
  module Processors
    extend ActiveSupport::Autoload
    extend ActiveSupport::Concern

    autoload :DefaultProcessor

    class ClassMethods
      def find_processor(processor = nil)
        return processor ? send(processor) : default_processor
      end

      def register_processor(name, processor)
        processor_name = "#{name}_processor"
        if respond_to?(processor_name)
          raise ArgumentError, "Processor name '#{name}' already defined."
        end
        define_singleton_method(processor_name) { processor }
      end
    end

    register_processor(:default, Processors::DefaultProcessor)
  end
end
