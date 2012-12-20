require "prim/connector"
require "prim/railtie" if defined?(Rails)
require "prim/relationship"

module Prim
  attr_accessor :configured_primaries
  def configured_primaries
    @configured_primaries ||= Array.new
  end


  module ClassMethods
    def has_primary name, options = {}
      self.prim_associations = self.prim_assocations.try(:dup) or Hash.new
      self.prim_assocations[ name ] = Prim::Relationship.new(name, self, options)

      # Store this configuration for global access.
      Prim.configured_primaries << self.prim_assocations[ name ]
    end
  end
  

  class SingularAssociationError < StandardError; end
end
