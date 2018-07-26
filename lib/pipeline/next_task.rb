# frozen_string_literal: true

module Pipeline
  class NextTask
    attr_reader :klass_name, :queue_name, :otions
    def initialize(klass_name, options)
      @klass_name = klass_name
      @queue_name = Pipeline::Task.klass_to_queue_name(klass_name)
      @options = options
    end
  end
end
