# frozen_string_literal: true

module Pipeline
  def self.report_error(job, error)
    Pipeline.logger.error("[EXCEPTION] #{error.class} #{error.message} in #{job.job_and_worker_id}")
  end
end
