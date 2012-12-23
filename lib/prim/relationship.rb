# require 'prim/instance_methods'

module Prim
  class Relationship

    attr_reader :reflection, :owning_class, :association_name, :options
    delegate :active_record, :source_reflection, :through_reflection, to: :reflection

    def initialize association_name, owning_class, options = {}
      @options = extract_options options
      @association_name = association_name
      @owning_class = owning_class
      @reflection   = owning_class.reflect_on_association( association_name )

      if reflection.nil?
        raise ArgumentError.new("Prim: Association '#{ association_name }' not found " +
          "on #{ owning_class.name }. Perhaps you misspelled it?")
      
      elsif !reflection.collection?
        raise Prim::SingularAssociationError.new("Prim: Association '#{ association_name }' " +
          "is not a one-to-many or many-to-many relationship, so it can't have a primary.")

      elsif !reflected_column_names.include? "primary"
        raise MissingColumnError.new("Prim: #{ owning_class.name } needs #{ reflected_class.name } " +
          "to have a boolean 'primary' column in order to have a primary #{ source_class.name }.")
      end

      # TODO: ensure the association isn't nested?

      # reflected_class.send :include, InstanceMethods::Reflected
      reflected_class.class_eval do
        before_create  :assign_primary
        before_update  :assign_primary
        before_destroy :assign_primary
      end

      reflected_class.instance_eval do
        def primary
          where(primary: true).first
        end
      end

      true
    end

    # The association method to call on the owning class to retrieve a record's collection.
    def collection_method
      options[:through] || mapping_reflection.plural_name
    end

    # The class of the source: i.e. Post if the owning class `has_many :posts`.
    def source_class
      source_reflection.klass
    end

    # The class of the `mapping_reflection`.
    def reflected_class
      mapping_reflection.klass
    end

    # The association reflection representing the link between the owning class and the
    # mapping class, whether or not the mapping class represents a join-table.
    def mapping_reflection
      through_reflection || source_reflection
    end

    # True if the `mapping_reflection` class has an "inverse" mapping back to the owning
    # class with a matching name. Verifies that a polymorphic mapping exists.
    def polymorphic_mapping?
      if polymorphic_as.present?
        !!reflected_class.reflect_on_all_associations.detect do |refl|
          refl.name == polymorphic_as and refl.association_class == ActiveRecord::Associations::BelongsToPolymorphicAssociation
        end
      end
    end

    # The name the owning class uses to create mappings in the reflected class; i.e. the
    # `:as` option set on the `has_many` association in the owner.
    def reflection_polymorphic_as
      mapping_reflection.options[:as].to_sym
    end

    # True if this relationship relies on a mapping table for `primary` records.
    def mapping_table?
      !!reflection.through_reflection
    end

    private

    # The columns of the reflected class (where `primary` needs to be).
    def reflected_column_names
      reflected_class.column_names
    end

    def extract_options options
      options
    end
  end
end
