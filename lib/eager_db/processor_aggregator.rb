module EagerDB
  class ProcessorAggregator
    def initialize(processor_classes)
      @processor_classes = processor_classes
    end

    def process(sql)
      results = @processor_classes.collect do |klass|
        klass.process(sql)
      end

      results.uniq
    end
  end
end
