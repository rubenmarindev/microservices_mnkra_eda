module EventPublishers
  class OrderPublisher
    EXCHANGE_NAME = "order.events"

    def self.publish_created(order)
      payload = {
        event_type: "order.created",
        order_id: order.id,
        customer_id: order.customer_id,
        product_name: order.product_name,
        quantity: order.quantity,
        price: order.price.to_s,
        status: order.status,
        timestamp: Time.current.iso8601
      }

      publish(payload)
      Rails.logger.info "OrderService: Published order.created event for Order ##{order.id}"
    end

    private

    def self.publish(payload)
      channel = RABBITMQ_CONNECTION.create_channel
      exchange = channel.topic(EXCHANGE_NAME, durable: true)
      routing_key = payload[:event_type]

      exchange.publish(payload.to_json, routing_key: routing_key, persistent: true)
    ensure
      channel&.close
    end
  end
end
