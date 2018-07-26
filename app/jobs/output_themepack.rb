# frozen_string_literal: true

require 'pipeline'

class OutputThemepack
  include Pipeline::Task

  def call
    puts "Done - #{job_data.inspect}"
  end
end
