require "active_support/core_ext/object/try"
require "prim/connector"
require "prim/helpers"
require "prim/railtie" if defined?(Rails)
require "prim/relationship"

module Prim
  class << self
    attr_accessor :configured_primaries
    def configured_primaries
      @configured_primaries ||= Array.new
    end
  end

  module ClassMethods
    include Prim::Helpers

    # TODO: allow multiple singular names in one call.
    def has_primary name, options = {}
      singular_name    = name.to_sym
      association_name = plural_sym(singular_name)

      self.prim_relationships = self.prim_relationships.try(:dup) || Hash.new
      self.prim_relationships[ singular_name ] = Prim::Relationship.new(association_name, self, options)

      # Store this configuration for global access.
      Prim.configured_primaries << self.prim_relationships[ singular_name ]

      define_method "primary_#{ singular_name }" do
        prim_collection_for(singular_name).primary
      end

      define_method "primary_#{ singular_name }=" do |instance|
        prim_collection_for(singular_name).primary = instance
      end

      define_method "#{ association_name }_with_primaries" do
        prim_collection_for(singular_name).all
      end

      alias_method_chain association_name, :primaries
    end
  end

  class SingularAssociationError < StandardError; end
  class InvalidPrimaryColumnError < StandardError; end
end
