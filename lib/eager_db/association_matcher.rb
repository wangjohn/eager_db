module EagerDB
  class SqlStatement
    attr_reader :raw_sql, :bind_values

    def initialize(raw_sql, bind_values = nil)
      @raw_sql = raw_sql
      @bind_values = bind_values
    end
  end

  class AssociationMatcher
    class << self

      attr_reader :match_sql, :preloads

      def match_on(sql, bind_values = nil)
        @match_sql = SqlStatement.new(sql, bind_values)
      end

      def preload(sql, bind_values = nil)
        (@preloads ||= []) << SqlStatement.new(sql, bind_values)
      end

      def result
        @result ||= AssociationMatcherResult.new(self)
      end

      def result_variable?(name)
        true
      end
    end
  end

  class AssociationMatcherResultVariable
    attr_reader :result, :name

    def initializer(result, name)
      @result = result
      @name = name
    end
  end

  class AssociationMatcherResult
    attr_reader :matcher

    def initialize(matcher)
      @matcher = matcher
    end

    def get_variable(name)
      AssociationMatcherResultVariable.new(matcher, name)
    end

    def method_missing(method, *args, &block)
      if matcher.result_variable?(method)
        get_variable(name)
      else
        super
      end
    end

    def respond_to?(method)
      if matcher.result_variable?(method)
        true
      else
        super
      end
    end
  end
end
