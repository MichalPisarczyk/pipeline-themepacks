# frozen_string_literal: true

require 'pipeline'

class ImageScanner
  include Pipeline::Task

  output do |map|
    map.next_task :ImageUploader
  end

  def call
    user = job_data['user']
    urls = (0..10).map { |num| "https://google.com/search?q=#{user}/#{num}.txt" }
    urls << 'https://www.livelinktechnology.net/'

    urls.each do |url|
      output_next("user=#{user}", 'url' => url)
    end
  end
end
