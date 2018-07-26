# frozen_string_literal: true

require 'json'

# Basic task
module Pipeline
  module Task
    def self.included(klass)
      return if Pipeline::Task.task_classes.include? klass
      klass.class_eval do
        attr_reader :job_data

        @queue ||= Pipeline::Task.klass_to_queue_name(klass)

        extend(ClassMethods)
        prepend(InstanceMethods)
      end
      Pipeline::Task.task_classes << klass
    end

    module ClassMethods
      def output
        yield(@router ||= Pipeline::NextTaskRouter.new(self)) if block_given?
        @router
      end

      def last_job?
        output.nil? || output.empty?
      end

      def perform(job_data)
        new(job_data).call_with_rescue
      end

      def queue_names
        [@queue]
      end

      def stats_key
        'stats:'+self.name
      end
    end

    module InstanceMethods
      def initialize(job_data)
        @job_data = job_data
      end

      def call_with_rescue
        Pipeline.logger.info("Starting #{job_and_worker_id} - #{job_data.to_json}")
        Resque.redis.incr(self.class.stats_key)
        call
        raise 'Task exited without output' unless @output_dispatched || self.class.last_job?
      rescue StandardError => e
        # Pipeline.report_failure(self, e)
        raise e
      else
        Pipeline.logger.info("Finished #{job_and_worker_id}")
      end

      def job_and_worker_id
        [Socket.gethostname, $$.to_s, self.class.name, job_path].join(';')
      end

      def job_path
        job_data['_pipeline_job_path']
      end

      def output_next(url_suffix, job_data)
        data = self.job_data.merge(job_data)
        data['_pipeline_job_path'] = [job_path, url_suffix].compact.join('/')
        output_raw(data)
      end

      def output_raw(job_data)
        @output_dispatched = true
        self.class.output.dispatch(job_data)
      end

      def no_output!
        @output_dispatched = true
      end
    end

    module_function

    def klass_to_queue_name(klass)
      # return klass if klass.is_a?(Symbol)
      # return klass.intern if klass.is_a?(String)
      klass = klass.to_s if klass.is_a?(Symbol)
      klass = klass.name if klass.is_a?(Module)
      string = (klass.gsub(/([a-z0-9])([A-Z])/) { |s| [s[0], '_', s[1]].join })
      string = string.gsub(/::/, '.')
      string.downcase.intern
    end

    def task_classes
      @task_classes ||= []
    end
  end
end
