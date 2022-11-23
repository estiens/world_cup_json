GoodJob::Engine.middleware.use(Rack::Auth::Basic) do |username, password|
  ActiveSupport::SecurityUtils.secure_compare(ENV.fetch('GOOD_JOB_LOGIN', 'goodjob'), username) &&
    ActiveSupport::SecurityUtils.secure_compare(ENV.fetch('GOOD_JOB_PASSWORD', 'goodjob'), password)
end

Rails.application.config.good_job = {
  preserve_job_records: true,
  retry_on_unhandled_error: false,
  on_thread_error: ->(exception) { Rails.logger.warn(exception) },
  max_threads: 10,
  shutdown_timeout: 60,
  queues: 'current,scheduler,scraping,noscrape,default',
  enable_cron: (ENV.fetch('ENABLE_CRON', false) || ENV.fetch('SCRAPING_ENABLED', false)),
  cleanup_preserved_jobs_before_seconds_ago: 60 * 60 * 24,
  cron: {
    clear_cache: {
      cron: '*/10 * * * *',
      class: 'ClearCacheJob'
    },
    scheduler_job: {
      cron: '*/1 * * * *',
      class: 'SchedulerJob'
    },
    in_progress_job: {
      cron: '*/1 * * * *',
      class: 'InProgressJob'
    }
  }
}
