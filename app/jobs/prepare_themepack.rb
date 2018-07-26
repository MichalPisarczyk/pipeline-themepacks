# frozen_string_literal: true

require 'pipeline'

class PrepareThemepack
  include Pipeline::Task

  output do |map|
    map.next_task :RenderThemepack
  end

  def call
    puts "Done - #{job_data.inspect}"

    output_next("rendered", {})
  end
end
