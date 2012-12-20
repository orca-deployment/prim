require 'active_support/inflector/methods'

module Prim
  class Relationship
    attr_reader :reflection, :kind
    delegate :source_reflection, :through_reflection, to: :reflection

    def initialize target_name, source_kind, options
      options = extract_options options
      @kind   = source_kind

      @reflection = kind.reflect_on_association( target_name.to_s.pluralize.to_sym )
      raise Prim::SingularAssociationError unless reflection.collection?

      # find out if the collection_association exists
      # determine if there's a through_reflection
      # ensure the association isn't nested?
    end

    private

    def extract_options options
      options
    end
  end
end
