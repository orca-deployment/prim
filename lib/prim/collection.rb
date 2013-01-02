module Prim
  # Collection largely wraps an association collection (like a Relation) but adds
  # the concept of a primary member. Collections can only exist in the context of
  # a Relationship (see Prim::Relationship for more info) and an "owning" `instance`,
  # and contain mapping records.
  class Collection

    # The members of a Collection are not necessarily the "source" records, or
    # the Tags if a Post `has_many :tags`. If a mapping table (say, "taggings")
    # lies between Post and Tag, a Collection's members will be Taggings instead.
    attr_reader :instance, :relationship, :members

    def initialize relationship, instance
      @instance     = instance
      @relationship = relationship

      # Attach this collection to the mapping class so it has access to static methods.
      relationship.reflected_class.prim_collection = self
    end

    def primary
      sources.where( relationship.through_reflection.name => { primary: true } ).first
    end

    def primary= source_record
      mapping = mapping_for(source_record)

      if source_record.persisted?
        if mapping.nil?
          create_mapping!(source_record)

        elsif !mapping.primary?
          mapping.update_attributes(primary: true)
        end

      else
        create_source_record!(source_record)
      end

      true
    end

    def siblings_for mapping
      foreign_key   = relationship.mapping_reflection.foreign_key
      mapping_type  = relationship.mapping_reflection.type
      mapping_class = relationship.reflected_class
      primary_key   = mapping_class.primary_key

      query = relationship.reflected_class.where( foreign_key => mapping[ foreign_key ] )
      query = query.where( mapping_type => mapping[ mapping_type ] ) unless mapping_type.nil?

      query.where( mapping_class.arel_table[ primary_key ].not_eq( mapping[ primary_key ] ) )
    end

    private

    # Creates a new source record and a mapping between it and the owner instance.
    def create_source_record! source_record
      if source_record.save
        create_mapping!(source_record)
      else
        false
      end
    end

    def create_mapping! source_record
      mappings.create( relationship.foreign_key => source_record.id, primary: true )
    end

    def mappings force_reload = false
      instance.send( relationship.collection_label, force_reload )
    end

    def sources force_reload = false
      instance.send( relationship.association_name, force_reload )
    end

    # Returns the mapping for a given source record. If this Relationship doesn't
    # involve a mapping table, returns the source record itself.
    def mapping_for source_record
      if relationship.mapping_table?
        mappings.detect do |member|
          member[ relationship.source_reflection.foreign_key ] == source_record.id
        end

      else
        source_record
      end
    end
  end
end
