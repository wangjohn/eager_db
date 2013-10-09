module EagerDB
  class EagerloadQueryJob
    def initialize(sql)
      @sql = sql
      @created_at = Time.now
    end

    def work
    end
  end
end
