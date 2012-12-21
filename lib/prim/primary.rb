module Prim
  class Primary
    attr_reader :relationship, :record

    def initialize relationship, record
      @relationship = relationship
      @record = record
      
    end
  end
end
