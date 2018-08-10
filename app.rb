require "bunny"
require "toxiproxy"
require "pp"
require "logger"

Toxiproxy.populate([{
  name: "rabbitmq",
  listen: "localhost:56722",
  upstream: "localhost:5672",
}])

STDOUT.sync = true
logger = Logger.new(STDOUT)

conn = Bunny.new("amqp://guest:guest@localhost:56722",
  logger: logger)
conn.start

ch = conn.create_channel

logger.info "Declaring Bob with ch.queue('Bob')..."
Toxiproxy[/rabbitmq/].downstream(:latency, latency: 20000).apply do
  begin
    ch.queue("Bob")
  rescue StandardError => e
    logger.warn "Exception: #{e}"
    logger.warn e.backtrace.join("\n")
  end
end

logger.info "Declaring Sally with ch.queue('Sally')..."
queue = ch.queue("Sally")
logger.info "Recived #{queue.name} for ch.queue('Sally')"

logger.info "Declaring Rick with ch.queue('Rick'))..."
queue = ch.queue("Rick")
logger.info "Recived #{queue.name} for ch.queue('Rick')"

logger.info "Declaring Bob again with ch.queue('Bob'))..."
queue = ch.queue("Bob")
logger.info "Recived #{queue.name} for ch.queue('Bob')"