module Prim
  # This class largely wraps ActiveRecord::Reflection::MacroReflection and its subclasses.
  # A Relationship encapsulates the interaction among the two or three classes involved in
  # a one-to-many or many-to-many model association, and reconfigures these classes to
  # make handling primary members of those associations simple.
  class Relationship

    attr_reader :reflection, :owning_class, :association_name, :options
    delegate :source_reflection, :through_reflection, :foreign_key, to: :reflection

    def initialize association_name, owning_class, options = {}
      @options = options
      @association_name = association_name
      @owning_class = owning_class
      @reflection   = owning_class.reflect_on_association( association_name )

      # TODO: remove these exceptions and replace with logged errors? hmm.
      if reflection.nil?
        raise ArgumentError.new("Association '#{ association_name }' not found " +
          "on #{ owning_class.name }. Perhaps you misspelled it?")
      
      elsif !reflection.collection?
        raise SingularAssociationError.new("Association '#{ association_name }' " +
          "is not a one-to-many or many-to-many relationship, so it can't have a primary.")

      elsif !primary_column
        # TODO: add a generator to automatically create a migration, then change this
        # message to give users the exact instruction needed.
        raise InvalidPrimaryColumnError.new("#{ owning_class.name } needs table " +
          "`#{ mapping_reflection.table_name }` to have a boolean 'primary' column " +
          "in order to have a primary #{ source_class.name }.")
      end

      # TODO: ensure the association isn't nested?

      reflected_class.send :include, InstanceMethods::Reflected
      reflected_class.class_attribute :prim_relationship
      reflected_class.prim_relationship = self

      source_class.send :include, InstanceMethods::Source if mapping_table?
    end

    # The association method to call on the owning class to retrieve a record's collection.
    def collection_label
      options[:through] || mapping_reflection.plural_name
    end

    # The class of the reflection source: i.e. Post if the owning class `has_many :posts`.
    def source_class
      reflection.klass
    end

    # The class of the `mapping_reflection`.
    def reflected_class
      mapping_reflection.klass
    end

    # The association reflection representing the link between the owning class and the
    # mapping class, whether or not the mapping class represents a join-table.
    def mapping_reflection
      through_reflection || reflection
    end

    # True if this relationship relies on a mapping table for `primary` records.
    def mapping_table?
      !!through_reflection
    end

    private

    def primary_column
      reflected_class.columns.find { |col| col.name == "primary" }
    end
  end
end
