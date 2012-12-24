module Prim
  # Collection largely wraps an association collection (like a Relation) but adds
  # the concept of a primary member. Collections can only exist in the context of
  # a Relationship (see Prim::Relationship for more info) and an `owner` instance,
  # and contain mapping records.
  class Collection

    # The members of a Collection are not necessarily the "source" records, or
    # the Tags if a Post `has_many :tags`. If a mapping table (say, "taggings")
    # lies between Post and Tag, a Collection's members will be Taggings instead.
    attr_reader :instance, :relationship, :members

    def initialize relationship, instance
      @instance = instance
      @relationship = relationship      
    end

    def primary
      reload_collection!
      members.primary
    end

    def primary= source_record
      # reload_collection!

      # check if this record is already primary
      # 
      
      if mapping = mapping_for(source_record)
        if mapping.primary?
          return true
        else
          demote_current_primary!
        end
      end

    end

    private

    def reload_collection!
      @members = instance.send( relationship.collection_method )
    end

    def mapping_for source_record
      if relationship.mapping_table?
        members.detect do |member|
          member[ reflection.source_reflection.foreign_key ] == source_record.id
        end
      end
    end
  end
end
