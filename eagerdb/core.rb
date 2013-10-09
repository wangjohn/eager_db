module EagerDB
  module Core
    def send_sql(sql)
      make_sql_call(sql)
      add_to_jobs_queue(sql)
    end

    def make_sql_call(sql)
    end

    def add_to_jobs_queue(sql)
    end
  end
end
