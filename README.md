# Pipeline


## Overview

A pipeline is a series of tasks that perform small jobs.  The expectation is that jobs will flow through the pipeline until they reach the terminal task, which will have no further actions.

A task is a derived from a Resque worker.  It should be a single class which includes the `Pipeline::Task` module and sits in the `app/jobs/` folder.

A job consists of a hash, with one internal parameter - `__pipeline_job_path` which is automatically appended with the first argument to `output_next(job_path_suffix, data_to_merge)`.

There is a TaskRouter which defines which job to enqueue next, optionally routing to different tasks based on the contents of the job.

**Example Task**

```ruby
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
```


## Configuration

Use the `REDIS_URL` environment variable to set the redis to connect to.  Otherwise the code will default to localhost on port 6379.

If you need redis sentinel support, then config.rb will need to be modified.

## API Methods


The following methods are available within a `Pipeline::Task`


`Pipeline::Task#job_data` - data payload passed in to job

`Pipeline::Task#job_and_worker_id` - job/worker identifier (used for logging)

`Pipeline::Task#job_path` - unique identifier for job, added to as the job progresses through the pipeline


`Pipeline::Task#output_next(suffix, data)` - queue a follow-on job

- `suffix` is a String and is appended to the job_path
- `data` is a Hash and is merged with `#job_data` to to produce the payload for the next job

`Pipeline::Task#no_output!` - should be called if there is a configured follow-on task, but the job decides to not enqueue another task.


## Entry Points

### Commands

See `Rakefile` for details.


`$ rake` lists known tasks and their potential outputs

`$ rake 'web[]'` runs the web server.  

Standard arguments can be passed comma-separated in the brackets, e.g. `rake web[foreground]` to run in the foregrounds.


`$ rake 'run[queue1,queue2]'` runs a single worker which will listen for (and process) jobs on `queue1` and `queue2` in that order.

For development, it's easiest to run `rake 'run[*]'` which will schedule a single worker to run all queues.
