# frozen_string_literal: true

require 'pry'
load './config.rb'

TRANSFORM_WEB_ARGS = Hash.new do |_hash, key|
  key
end.merge({
            'status' => '--status',
            'foreground' => '--foreground',
            'debug' => '--debug',
            'no-launch' => '--no-launch',
            'help' => '--help',
            'version' => '--version',
            'kill' => '--kill'
          })

desc 'Run webserver'
task :web do |_task, args|
  $LOAD_PATH << Dir.pwd + '/lib'
  require 'pipeline'

  Dir.glob('app/jobs/*.rb').each { |job| load job }

  require 'resque/server'
  require 'vegas'
  require 'pipeline/web'

  Vegas::Runner.new(Resque::Server, 'resque-web', {before_run: lambda { |v|
                                                                path = (ENV['RESQUECONFIG'])
                                                                load path.to_s.strip if path
                                                              }}, args.extras.map { |arg| TRANSFORM_WEB_ARGS[arg] }) do |runner, opts, _app|
    opts.on('-N NAMESPACE', '--namespace NAMESPACE', 'set the Redis namespace') do |namespace|
      runner.logger.info "Using Redis namespace '#{namespace}'"
      Resque.redis.namespace = namespace
    end
    opts.on('-r redis-connection', '--redis redis-connection', 'set the Redis connection string') do |redis_conf|
      runner.logger.info "Using Redis connection '#{redis_conf}'"
      Resque.redis = redis_conf
    end
    opts.on('-a url-prefix', '--append url-prefix', 'set reverse_proxy friendly prefix to links') do |url_prefix|
      runner.logger.info "Using URL Prefix '#{url_prefix}'"
      Resque::Server.url_prefix = url_prefix
    end
  end
end

desc 'Default task'
task :run, :queue do |_task, args|
  $LOAD_PATH << Dir.pwd + '/lib'
  require 'pipeline'

  Dir.glob('app/jobs/*.rb').each { |job| load job }

  queues = [args.queue, *args.extras].compact

  puts "Checking #{queues.inspect}"
  worker = Resque::Worker.new(*queues)
  worker.prepare
  worker.work
end

desc 'Default task'
task :default do
  $LOAD_PATH << Dir.pwd + '/lib'
  require 'pipeline'

  Dir.glob('app/jobs/*.rb').each { |job| load job }

  Pipeline.report!
end
