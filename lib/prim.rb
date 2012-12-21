require "active_support/core_ext/object/try"
require "prim/connector"
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
    def has_primary name, options = {}
      self.prim_associations = self.prim_associations.try(:dup) || Hash.new
      self.prim_associations[ name ] = Prim::Relationship.new(name, self, options)

      # Store this configuration for global access.
      Prim.configured_primaries << self.prim_associations[ name ]

      define_method
    end
  end

  class SingularAssociationError < StandardError; end
  class MissingColumnError < StandardError; end
end
