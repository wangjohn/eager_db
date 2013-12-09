module EagerDB
  module Prediction
    extend ActiveSupport::Autoload

    autoload :MarkovProbabilityStorage
    autoload :ProbabilityCalculator
    autoload :SqlLog
  end
end
