require "active_support"

module EagerDB
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :Core
  autoload :EagerloadQueryJob
  autoload :Processor
end

p EagerDB::Processor
