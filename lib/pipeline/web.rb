# frozen_string_literal: true

require 'resque/server'

module Pipeline
  module Web
    VIEW_PATH = File.join(File.dirname(__FILE__), 'web', 'views')

    def self.registered(app)
      app.get('/tasks') { pipeline_view(:tasks) }
      app.tabs << 'Tasks'

      app.helpers do
        def pipeline_view(filename, options = {}, locals = {})
          erb(File.read(File.join(::Pipeline::Web::VIEW_PATH, "#{filename}.erb")), options, locals)
        end
      end
    end
  end
end


Resque::Server.register Pipeline::Web
