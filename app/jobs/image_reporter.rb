# frozen_string_literal: true

require 'pipeline'

class ImageReporter
  include Pipeline::Task

  def call
    puts "Done - #{job_data.inspect}"
  end
end
