module Prim
  # Collection wraps an association collection (like a Relation).
  class Collection
    attr_reader :instance, :relationship, :members

    def initialize instance, relationship
      @instance = instance
      @relationship = relationship      
    end

    def primary
      reload_collection!
      members.primary
    end

    private

    def reload_collection!
      @members = instance.send( relationship.collection_method )
    end
  end
end
