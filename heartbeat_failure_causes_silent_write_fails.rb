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
  automatically_recover: true,
  threaded: false)
conn.start

ch = conn.create_channel(nil, 0)
logger.info "Declaring Bob with ch.queue('Bob')..."
ch.queue("Bob")
Toxiproxy[/rabbitmq/].down do
  sleep 3
  logger.info "Push some data to Bob"
  ch.queue("Bob").publish("Some data")
  logger.info "Silently fails because transport#write does nothing if not open"
end