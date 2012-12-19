# require 'prim/callbacks'
# require 'prim/validators'
# require 'prim/schema'
require "prim/instance_methods"

module Prim
  module Connector
    def self.included base
      base.extend ClassMethods
      base.send :include, InstanceMethods
      # base.send :include, Callbacks
      # base.send :include, Validators
      # base.send :include, Schema if defined? ActiveRecord
      base.class_attribute :prim_associations

      # locale_path = Dir.glob(File.dirname(__FILE__) + "/locales/*.{rb,yml}")
      # I18n.load_path += locale_path unless I18n.load_path.include?(locale_path)
    end
  end
end
