require "bunny"
require "toxiproxy"
require "pp"
require "logger"
require "pry-byebug"

Toxiproxy.populate([{
  name: "rabbitmq",
  listen: "localhost:56722",
  upstream: "localhost:5672",
}])

STDOUT.sync = true
logger = Logger.new(STDOUT)
Toxiproxy[/rabbitmq/].enable # Just in case it's in a bad state
conn = Bunny.new("amqp://guest:guest@localhost:56722",
  logger: logger,
  heartbeat_timeout: 3,
  automatically_recover: false,
  threaded: false)
conn.start

ch = conn.create_channel(nil, 0)

begin
  logger.info "Declaring Bob with ch.queue('Bob')..."
  ch.queue("Bob")
  Toxiproxy[/rabbitmq/].down do
    (0..20).each do |i|
      now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      if @last_run_time
        logger.info "I'm and app working ##{i}: Time since last run #{now - @last_run_time}"
      else
        logger.info "I'm and app working ##{i}"
      end
      @last_run_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      sleep 1
    end
  end
rescue Exception => e
  logger.error "Exception that killed this process: #{e} #{e.message}\n#{e.backtrace.join("\n\t")}"
  logger.error "Exception cause that killed this process: #{e.cause} #{e.cause.message}\n#{e.cause.backtrace.join("\n\t")}" if e.cause
end