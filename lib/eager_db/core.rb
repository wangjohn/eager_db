require 'resque'

module EagerDB
  module Core
    def initialize
      @resque = Resque.new
    end

    # This is going to hijack the exec_query() method in the 
    # connection adapters in ActiveRecord.
    def exec_query(sql, name = nil, binds = [])
      result = super
      create_job(sql)
      result
    end

    def create_job(sql)
      Resque.enqueue(EagerloadQueryJob, sql, Time.now)
    end
  end
end

