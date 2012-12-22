require 'active_support/inflector/methods'

module Prim
  module Helpers
    def plural_sym singular_sym
      singular_sym.to_s.pluralize.to_sym
    end

    def singular_sym plural_sym
      plural_sym.to_s.singularize.to_sym
    end
  end
end
