require 'bunny'

RABBITMQ_CONNECTION = Bunny.new(
  #host: ENV.fetch("RABBITMQ_HOST", "rabbitmq"),
  host: ENV.fetch("RABBITMQ_HOST", "localhost"),
  user: ENV.fetch("RABBITMQ_USER", "guest"),
  password: ENV.fetch("RABBITMQ_PASSWORD", "guest")
)

if !RABBITMQ_CONNECTION.connected?
  RABBITMQ_CONNECTION.start
  puts "✅ OrderService: RabbitMQ connection established."
end

at_exit do
  if RABBITMQ_CONNECTION.connected?
    RABBITMQ_CONNECTION.close
    puts "🛑 OrderService: RabbitMQ connection closed."
  end
end
