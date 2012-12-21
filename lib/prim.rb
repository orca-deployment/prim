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

    def has_primary name, options = {}
      singular_name = name.to_sym
      association_name = plural_sym(singular_name)

      self.prim_associations = self.prim_associations.try(:dup) || Hash.new
      self.prim_associations[ singular_name ] = Prim::Relationship.new(singular_name, self, options)

      # Store this configuration for global access.
      Prim.configured_primaries << self.prim_associations[ singular_name ]

      define_method "primary_#{ singular_name }" do
        
      end

      define_method "primary_#{ singular_name }=" do |record|
        primary_for association_name
      end

      define_method "primary_#{ singular_name }?" do
        !!primary_for association_name
      end
    end
  end

  class SingularAssociationError < StandardError; end
  class MissingColumnError < StandardError; end
end
