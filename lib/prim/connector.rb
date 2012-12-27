require "prim/instance_methods"

module Prim
  module Connector
    def self.included base
      base.send :extend,  ClassMethods
      base.send :include, InstanceMethods::Owner
      
      base.class_attribute :prim_relationships
    end
  end
end
