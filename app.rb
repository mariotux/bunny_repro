require "bunny"
require "toxiproxy"
require "pp"

Toxiproxy.populate([{
  name: "rabbitmq",
  listen: "localhost:56722",
  upstream: "localhost:5672",
}])

STDOUT.sync = true

conn = Bunny.new("amqp://guest:guest@localhost:56722", continuation_timeout: 1000)
conn.start

ch = conn.create_channel

print "Declaring Bob..."
Toxiproxy[/rabbitmq/].downstream(:latency, latency: 2000).apply do
  begin
    ch.queue("Bob")
  rescue StandardError => e
    print " got: "
    pp e
  end
end

print "Declaring Sally..."
queue = ch.queue("Sally")
print " got: "
pp queue

print "Declaring Rick..."
queue = ch.queue("Rick")
print " got: "
pp queue

puts "Declaring Bob..."
queue = ch.queue("Bob")
print " got: "
pp queue
