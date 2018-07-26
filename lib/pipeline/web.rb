# frozen_string_literal: true

require 'resque/server'

module Pipeline
  module Web
    VIEW_PATH = File.join(File.dirname(__FILE__), 'web', 'views')

    def self.registered(app)
      app.get('/tasks') { pipeline_view(:tasks) }

      app.get('/enqueue') { pipeline_view(:entry) }

      app.post('/enqueue-tp') do
        session[:message] = nil
        unless theme_to_queue == ''
          Resque.enqueue_to('prepare_themepack', PrepareThemepack, job_spec)
          session[:message] = "You queued a render for: #{theme_to_queue}"
        end
        redirect '/enqueue'
      end

      app.tabs << 'Tasks'
      app.tabs << 'Enqueue'

      app.helpers do
        def pipeline_view(filename, options = {}, locals = {})
          erb(File.read(File.join(::Pipeline::Web::VIEW_PATH, "#{filename}.erb")), options, locals)
        end

        def theme_to_queue
          params[:theme_to_queue]
        end

        def job_spec
          {
            _pipeline_job_url: 'preparethemepacks',
            themepack: theme_to_queue
          }
        end
      end
    end
  end
end


Resque::Server.register Pipeline::Web
