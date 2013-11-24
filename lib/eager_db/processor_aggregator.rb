module EagerDB
  class ProcessorAggregator
    def initialize(processor_classes)
      @processor_classes = processor_classes
    end

    def process(eagerload_query_job)
      results = @processor_classes.collect do |klass|
        klass.process(eagerload_query_job)
      end

      results.uniq
    end
  end
end
