# frozen_string_literal: true

require 'pipeline'

class RenderThemepack
  include Pipeline::Task

  output do |map|
    map.next_task :OutputThemepack, if: ->(job) { job['render_success'] }
    map.next_task :RenderThemepack, if: ->(job) { !job['render_success'] && job['render_retries'] <= 3 }
  end

  def call
    puts "Attempt to render: #{job_data['themepack']}"
    
    cmd = [
      '/app/web-prism/prism',
      'tp-cache-web',
      job_data['themepack']
    ]
    system *cmd
    
    output_next("rendered", 'render_success' => true, 'render_retries' => render_retries )
  rescue StandardError => e
    Pipeline.logger.error e
    output_next('failed_render', 'render_success' => false, 'render_retries' => render_retries)
  end
  
  def render_retries
    job_data['render_retries'] ||= 0
    job_data['render_retries'] += 1
  end
end
