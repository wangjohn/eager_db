require "active_support/dependencies/autoload"

module EagerDB
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :Core
  autoload :EagerloadQueryJob
end
