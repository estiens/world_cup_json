GoodJob::Engine.middleware.use(Rack::Auth::Basic) do |username, password|
  ActiveSupport::SecurityUtils.secure_compare(Rails.application.credentials.good_job_login, username) &&
    ActiveSupport::SecurityUtils.secure_compare(Rails.application.credentials.good_job_password, password)
end

Rails.application.configure do
  # Configure options individually...
  config.good_job.preserve_job_records = true
  config.good_job.retry_on_unhandled_error = false
  config.good_job.on_thread_error = ->(exception) { Sentry.capture_exception(exception) }
  config.good_job.execution_mode = :async
  config.good_job.queues = '*'
  config.good_job.max_threads = 5
  config.good_job.poll_interval = 30 # seconds
  config.good_job.shutdown_timeout = 25 # seconds
  config.good_job.enable_cron = true
  config.good_job.cron = { example: { cron: '0 * * * *', class: 'ExampleJob' } }

  # ...or all at once.
  config.good_job = {
    preserve_job_records: true,
    queues: 'scraping,noscrape,scheduler,default',
    enable_cron: ENV.fetch('ENABLE_CRON', false),
    cron: {
      scheduler_job: {
        cron: '*/1 * * * *',
        class: 'SchedulerJob'
      }
    }
  }
end
