require 'prim/helpers'

module Prim
  module InstanceMethods
    include Prim::Helpers

    attr_reader :_prim_relationship

    def primary_for association_name

    end

    def collection_for association_name
      @_prim_collections ||= {}
      @_prim_collections[ association_name ] ||= Collection.new(prim_relationships[ singular_sym(association_name) ], self)
    end

    def assign_primary singular_name, source_record
      @_prim_relationship = self.class.prim_relationships[ singular_name ]
      return false unless source_record.is_a? _prim_relationship.source_class

      # You can pass an existing record to promote it to Primary as long as that record
      # is already a member of the owning class's collection (see Prim::InstanceMethods#prim_collection).
      if source_record.persisted?
        if _prim_relationship.mapping_table?
          through_record = source_record.send
        end

      # Otherwise passing a new record will create a new mapping, but only if there's no
      # intermediate mapping class (because creating new source records will need more thought).
      elsif !_prim_relationship.mapping_table?

      else
        raise Prim::InvalidPrimaryError.new("source record doesn't exist! can't create source AND mapping records")
      end
    end

    def prim_collection association_name = nil
      @prim_collection ||= self.class.send
        (association_name ? self.class.prim_relationships[ association_name ] : _prim_relationship).collection_method
    end

    private

    def demote_current_primary!
    end
  end
end
