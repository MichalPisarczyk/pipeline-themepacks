# frozen_string_literal: true

require 'logger'
require 'pipeline/task'
require 'pipeline/next_task_router'
require 'pipeline/next_task'

module Pipeline
  module_function

  attr_writer :logger
  def logger
    @logger ||= Logger.new(STDERR)
  end

  def report!
    Pipeline::Task.task_classes.each do |klass|
      puts "[#{klass}]"
      klass.output&.each do |route|
        puts " -> #{route.klass}"
      end
    end
  end
end
