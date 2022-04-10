module Logs
  class Base
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def search
      execute.map { |element|  { id: element[comment], object: element[object], created_at: element[created_at] } }
    end

    def execute
      fail NotImplementedError
    end

    def object
      fail NotImplementedError
    end

    def comment
      fail NotImplementedError
    end

    def created_at
     fail NotImplementedError
   end

  end
end
