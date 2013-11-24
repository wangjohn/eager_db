require "active_support"

module EagerDB
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :Core
  autoload :EagerloadQueryJob
  autoload :Processors
  autoload :ProcessorAggregator
  autoload :SqlStatement
end
