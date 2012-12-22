require 'prim/helpers'

module Prim
  module InstanceMethods
    include Prim::Helpers

      def primary_for association_name

      end

      def assign_primary singular_name, source_record
        @_prim_relationship = self.class.prim_relationships[ singular_name ]
        return false unless source_record.is_a? @_prim_relationship.source_class

        # You can pass an existing record to promote it to Primary as long as that record
        # is already a member of the owning class's collection (see Prim::Relationship#collection).
        if source_record.persisted?
          if @_prim_relationship.mapping_table?
            # through_record = source_record.send
          end

          if false
            demote_current_primary!
          else
            raise Prim::InvalidPrimaryError.new
          end

        else
        end
      end

      private

      def demote_current_primary!
        collection.where(primary: true).first.try do |record|
          record.update_column :primary, false
        end
      end
    end
  end
end
