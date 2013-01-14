require 'prim/collection'
require 'active_support/concern'

module Prim
  module InstanceMethods

    module Owner
      extend ActiveSupport::Concern

      def prim_collection_for singular_name
        @_prim_collections ||= {}
        @_prim_collections[ singular_name ] ||= Prim::Collection.new(self.class.prim_relationships[ singular_name ], self)
      end

      included do
        alias_method :assign_prim_collection_for, :prim_collection_for
      end
    end

    module Reflected
      extend ActiveSupport::Concern

      included do
        validate :only_one_primary

        def self.primary
          where( primary: true ).first
        end
      end

      def only_one_primary
        if self[:primary]
          siblings.update_all('"primary" = false')
        elsif siblings.where( primary: true ).first.nil?
          self[:primary] = true
        end
      end

      # Builds a query selecting all siblings for a given mapping record. A record's
      # siblings are any records in the table of the `reflected_class` that match
      # the given record's foreign key and, if the association is polymorphic,
      # its foreign type. The set of siblings *excludes* `self` (this record).
      def siblings
        foreign_key  = prim_relationship.mapping_reflection.foreign_key
        mapping_type = prim_relationship.mapping_reflection.type
        primary_key  = prim_relationship.reflected_class.primary_key

        # Select all by foreign key first, to handle all cases.
        query = self.class.where( foreign_key => self[ foreign_key ] )

        # Only select by a foreign "type" column if one is used on the `reflected_class`,
        # making it a polymorphic association.
        unless mapping_type.nil?
          query = query.where( mapping_type => self[ mapping_type ] )
        end

        # Exclude this record from the query.
        query.where( self.class.arel_table[ primary_key ].not_eq( self[ primary_key ] ) )
      end
    end

    module Source
      extend ActiveSupport::Concern

      included do
        attr_writer :primary

        def primary
          @primary || false
        end

        def primary?
          primary
        end
      end
    end

  end
end
