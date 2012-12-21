require 'prim/helpers'

module Prim
  class Relationship
    include Prim::Helpers
    
    attr_reader :reflection, :self_class
    delegate :active_record, :source_reflection, :through_reflection, to: :reflection

    def initialize target_name, self_class, options
      options = extract_options options

      @self_class = self_class
      @reflection = self_class.reflect_on_association( plural_sym(target_name) )

      if reflection.nil?
        raise ArgumentError("Association '#{ plural_sym(target_name) }' not found \
          on #{ self_class.name }. Perhaps you misspelled it?")
      
      elsif !reflection.collection?
        raise Prim::SingularAssociationError("Association '#{ plural_sym(target_name) }' \
         is not a one-to-many or many-to-many relationship, so it can't have a primary.")
      end

      raise MissingColumnError(missing_column_message) unless reflected_column_names.include?("primary")
      # ensure the association isn't nested?
    end

    def source_class
      source_reflection.klass
    end

    def reflected_class
      (through_reflection || source_reflection).klass
    end

    def reflected_column_names
      reflected_class.column_names
    end

    private

    def mapping_table?
      !!reflection.through_reflection
    end

    def missing_column_message
      "Prim: #{ self_class.name } needs #{ reflected_class.name } to have a boolean 'primary' column \
      in order to be able to set primary #{ source_class.name } members."
    end

    def extract_options options
      options
    end
  end
end
