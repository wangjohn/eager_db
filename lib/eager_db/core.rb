require 'resque'

module EagerDB
  module Core
    def initialize
      @resque = Resque.new
    end

    def send_sql(sql)
      result = execute(sql)
      create_job(sql)
      result
    end

    def execute(sql)
    end

    def create_job(sql)
      Resque.enqueue(EagerloadQueryJob, sql, Time.now)
    end
  end
end

