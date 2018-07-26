# frozen_string_literal: true

require 'active_support/inflector'

module Pipeline
  class NextTaskRouter
    Route = Struct.new(:conditions, :next_task)
    class Route
      def matches?(job_data)
        conditions.call(job_data)
      end

      def dispatch(job_data)
        Resque.enqueue_to(queue_name, klass, job_data)
      end

      def queue_name
        next_task.queue_name
      end

      def klass
        next_task.klass_name.to_s.constantize
      end
    end

    def initialize(parent_class)
      @parent_class = parent_class
      @routes = []
    end

    def next_task(klass_name, options = {})
      conditions = options.delete(:if)
      conditions ||= ->(_data) { true }
      @routes.push(Route.new(conditions, Pipeline::NextTask.new(klass_name, options)))
    end

    def each(&block)
      @routes.each(&block)
    end

    def dispatch(job_data)
      @routes.each do |route|
        route.dispatch(job_data) if route.matches?(job_data)
      end
    end
  end
end
