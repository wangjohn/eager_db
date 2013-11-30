require "active_support"

module EagerDB
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :CommunicationChannel
  autoload :Core
  autoload :Endpoints
  autoload :EagerloadQueryJob
  autoload :MatchSql
  autoload :Processors
  autoload :ProcessorAggregator
  autoload :SqlStatement
  autoload :QueryResult
end
