require 'active_support/core_ext/object/try'

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
    end

    # Loads the primary member of this collection.
    def primary
      sources.where( relationship.collection_label => { primary: true } ).first.try do |record|
        record.primary = true
        record
      end
    end

    # Sets the primary member of this collection. Requires a `source_record` to
    # be passed (i.e. a Tag if Post `has_many :tags, through: :taggings`).
    def primary= source_record
      # Ensure what's passed can be set as the primary.
      return true unless source_record.is_a? relationship.source_class

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

    def all options = {}
      options[:with_primaries] ||= true

      if options[:with_primaries]
        primary_member = primary
        sources.tap do |records|
          records.find { |r| r == primary_member }.try(:primary=, true)
          records
        end
      else
        sources
      end
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

    def mappings
      instance.association( relationship.collection_label ).proxy
    end

    def sources
      instance.association( relationship.association_name ).proxy
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
