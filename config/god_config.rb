
RAILS_ROOT = "/home/shopdev/rails_apps/SoletronDev"

%w{12002 12003 12004}.each do |port|

  God.watch do |w|
    w.name ="soletron-dev-osiris-#{port}"
    w.interval = 60.seconds # default      


    w.start = "RAILS_ENV=production SERVER=shop thin -d -e production -c #{RAILS_ROOT} -p #{port} start"
    w.stop = "RAILS_ENV=production SERVER=shop thin -d -e production -c #{RAILS_ROOT} -p #{port} stop"


    w.restart = "RAILS_ENV=production SERVER=shop thin -d -e production -c #{RAILS_ROOT} -p #{port} restart"


    w.start_grace = 60.seconds
    w.restart_grace = 60.seconds
    w.pid_file = File.join(RAILS_ROOT, "/tmp/pids/thin.#{port}.pid")
    w.log = File.join(RAILS_ROOT, "/log/#{w.name}.log")

puts "the log file is #{w.log}"
    
    w.behavior(:clean_pid_file)

    w.start_if do |start|
      start.condition(:process_running) do |c|
        c.interval = 5.seconds
        c.running = false
      end
    end
    
    w.restart_if do |restart|
      restart.condition(:memory_usage) do |c|
        c.above = 150.megabytes
        c.times = [3, 5] # 3 out of 5 intervals
      end
    
      restart.condition(:cpu_usage) do |c|
        c.above = 50.percent
        c.times = 5
      end
    end
    
    # lifecycle
    w.lifecycle do |on|
      on.condition(:flapping) do |c|
        c.to_state = [:start, :restart]
        c.times = 5
        c.within = 5.minute
        c.transition = :unmonitored
        c.retry_in = 10.minutes
        c.retry_times = 5
        c.retry_within = 2.hours
      end
    end
  end
end
