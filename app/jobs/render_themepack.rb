# frozen_string_literal: true

require 'pipeline'

class RenderThemepack
  include Pipeline::Task

  output do |map|
    map.next_task :OutputThemepack
  end

  def call
    puts "Done - #{job_data.inspect}"

    output_next("rendered")
  end
end
