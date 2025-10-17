require 'json'
require 'active_record'

class OrderCreatedConsumer
  EXCHANGE_NAME = "order.events"
  QUEUE_NAME = "customer_service.order_events" # Cola específica para este servicio
  ROUTING_KEY = "order.created" # Qué eventos queremos escuchar

  def self.start
    # Cargar el entorno de Rails para acceder a modelos y configuración
    Rails.application.config.reload_classes_only_on_hmr = false
    Rails.application.credentials.key
    Rails.application.eager_load!
    ActiveRecord::Base.establish_connection(Rails.application.config.database_configuration[Rails.env])

    channel = RABBITMQ_CONNECTION.create_channel
    exchange = channel.topic(EXCHANGE_NAME, durable: true)

    queue = channel.queue(QUEUE_NAME, durable: true, exclusive: false, auto_delete: false)
    queue.bind(exchange, routing_key: ROUTING_KEY)

    Rails.logger.info "CustomerService: Waiting for '#{ROUTING_KEY}' events in queue '#{QUEUE_NAME}'. To exit press CTRL+C"

    begin
      queue.subscribe(manual_ack: true, block: true) do |delivery_info, properties, body|
        Rails.logger.info "CustomerService: [📥] Received event: #{body}"
        payload = JSON.parse(body)

        handle_order_created_event(payload)

        channel.ack(delivery_info.delivery_tag)
        Rails.logger.info "CustomerService: [ACK] Event acknowledged."
      rescue StandardError => e
        Rails.logger.error "CustomerService: [ERROR] Failed to process event: #{e.message}\n#{e.backtrace.join("\n")}"
      end
    rescue Interrupt => _
      Rails.logger.info "CustomerService: [🛑] Shutting down consumer..."
      channel.close
      RABBITMQ_CONNECTION.close
      exit(0)
    end
  end

  private

  def self.handle_order_created_event(payload)
    customer_id = payload["customer_id"]
    customer = Customer.find_by(id: customer_id)

    if customer
      ActiveRecord::Base.transaction do
        customer.orders_count ||= 0
        customer.update!(orders_count: customer.orders_count + 1)
        Rails.logger.info "CustomerService: Updated orders_count for Customer ##{customer.id}. New count: #{customer.orders_count}"
      end
    else
      Rails.logger.warn "CustomerService: Customer ##{customer_id} not found for order creation event."
    end
  rescue StandardError => e
    Rails.logger.error "CustomerService: Transaction failed for order event. Rolling back. Error: #{e.message}"
    raise
  end
end
