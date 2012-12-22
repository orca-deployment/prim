module Prim
  module Callbacks
    def self.included(base)
      base.send :extend,  Defining
      base.send :include, Running
    end

    module Defining
      def define_prim_callbacks(*callbacks)
        define_callbacks *[callbacks, { terminator: "result == false" }].flatten
        callbacks.each do |callback|
          eval <<-end_callbacks
            def before_#{callback}(*args, &blk)
              set_callback(:#{callback}, :before, *args, &blk)
            end
            def after_#{callback}(*args, &blk)
              set_callback(:#{callback}, :after, *args, &blk)
            end
          end_callbacks
        end
      end
    end

    module Running
      def run_prim_callbacks(callback, &block)
        run_callbacks(callback, &block)
      end
    end
  end
end
