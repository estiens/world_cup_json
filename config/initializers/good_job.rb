GoodJob::Engine.middleware.use(Rack::Auth::Basic) do |username, password|
  ActiveSupport::SecurityUtils.secure_compare(ENV.fetch('GOOD_JOB_LOGIN', 'goodjob'), username) &&
    ActiveSupport::SecurityUtils.secure_compare(ENV.fetch('GOOD_JOB_PASSWORD', 'goodjob'), password)
end

Rails.application.config.good_job = {
  preserve_job_records: true,
  retry_on_unhandled_error: false,
  queues: 'scraping,noscrape,scheduler,default',
  enable_cron: ENV.fetch('ENABLE_CRON', false),
  cron: {
    scheduler_job: {
      cron: '*/5 * * * *',
      class: 'SchedulerJob'
    },
    in_progress_job: {
      cron: '*/1 * * * *',
      class: 'MatchInProgressJob'
    }
  }
}
