# frozen_string_literal: true

require 'resque'

Resque.redis = Redis.new(url: 'redis://redis')
