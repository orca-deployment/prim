require "prim"
# require 'paperclip/schema'

module Prim
  require "rails"

  class Railtie < Rails::Railtie
    initializer "prim.insert_into_active_record" do |app|
      ActiveSupport.on_load :active_record do
        # Prim::Railtie.insert
        ActiveRecord::Base.send(:include, Prim::Connector) if defined?(ActiveRecord)
      end
    end

    # rake_tasks do
    #   load "tasks/prim.rake"
    # end
  end

  # class Railtie
  #   def self.insert
  #     ActiveRecord::Base.send(:include, Prim::Connector) if defined?(ActiveRecord)
  #   end
  # end
end
