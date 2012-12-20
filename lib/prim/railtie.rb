require "prim"

module Prim
  require "rails"

  class Railtie < Rails::Railtie
    initializer "prim.insert_into_active_record" do |app|
      ActiveSupport.on_load :active_record do
        ActiveRecord::Base.send(:include, Prim::Connector) if defined?(ActiveRecord)
      end
    end

    # rake_tasks do
    #   load "tasks/prim.rake"
    # end
  end
end
