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
      singular_name    = name.to_sym
      association_name = plural_sym(singular_name)

      self.prim_relationships = self.prim_relationships.try(:dup) || Hash.new
      self.prim_relationships[ singular_name ] = Prim::Relationship.new(association_name, self, options)

      # Store this configuration for global access.
      Prim.configured_primaries << self.prim_relationships[ singular_name ]

      define_method "primary_#{ singular_name }" do
        primary_for association_name
      end

      define_method "primary_#{ singular_name }=" do |record|
        # self.class.prim_relationships[ singular_name ].reflected_class.assign_primary
        assign_primary singular_name, record
      end
    end
  end

  class SingularAssociationError < StandardError; end
  class MissingColumnError < StandardError; end
end
