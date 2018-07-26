# frozen_string_literal: true

require 'pipeline'
require 'curl'

class ImageUploader
  include Pipeline::Task

  output do |map|
    map.next_task :ImageReporter, if: ->(job) { job['status'] == 200 }
    map.next_task :ImageUploader, if: ->(job) { job['status'] != 200 && job['attempts'] < 5 }
  end

  def call
    curl = Curl::Easy.new(job_data['url'])
    curl.get
    output_next('uploaded', 'status' => curl.status.to_i, 'attempts' => job_data['attempts'].to_i + 1)
  end
end
