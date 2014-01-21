# Inspired from - http://pinds.com/2010/11/24/tracking-errors-in-collectiveideas-delayedjob-using-exceptional/
if !Exceptional::Config.api_key.nil? and (Rails.env.production? or Rails.env.staging?)
  begin
    class Delayed::Worker
      def handle_failed_job_with_exceptional(job, error)
        Exceptional.handle(error, "Delayed::Job #{self.name}")
        handle_failed_job_without_exceptional(job, error)
        Exceptional.clear!
      end
      alias_method_chain :handle_failed_job, :exceptional
    end
  rescue => e
    STDERR.puts "Problem starting Exceptional for Delayed-Job. Your app will run as normal."
    Exceptional.logger.error(e.message)
    Exceptional.logger.error(e.backtrace)
  end
end
