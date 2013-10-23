require 'resque'

module EagerDB
  module Core
    # This is going to hijack the exec_query() method in the 
    # connection adapters in ActiveRecord.
    def execute(sql, binds = [])
      result = super
      create_job(sql, result)
      result
    end

    def create_job(sql, result)
      Resque.enqueue(EagerloadQueryJob, sql, result, Time.now)
    end
  end
end

