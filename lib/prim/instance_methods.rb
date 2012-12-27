require 'prim/collection'
require 'active_support/concern'

module Prim
  module InstanceMethods

    module Owner
      def get_primary singular_name
        collection_for(singular_name).primary
      end

      def assign_primary singular_name, instance
        collection_for(singular_name).primary = instance
      end

      def collection_for singular_name
        @_prim_collections ||= {}
        @_prim_collections[ singular_name ] ||= Prim::Collection.new(self.class.prim_relationships[ singular_name ], self)
      end
    end

    module Reflected
      extend ActiveSupport::Concern

      included do

        validate :only_one_primary

        def only_one_primary
          if self[:primary]
            siblings.update_all('"primary" = false')
          end
        end

      end
    end

  end
end
