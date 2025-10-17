# customer_service/spec/workers/order_created_consumer_spec.rb
require 'rails_helper'

RSpec.describe OrderCreatedConsumer, type: :worker do
  let!(:customer) { create(:customer, id: 101, name: 'Test Customer', address: 'Test Address', orders_count: 2) }
  let(:order_created_payload) do
    {
      "event_type" => "order.created",
      "order_id" => 500,
      "customer_id" => customer.id,
      "total_amount" => "150.0",
      "status" => "pending",
      "order_items" => [
        { "product_id" => 1, "quantity" => 1, "price_at_order" => "100.0" },
        { "product_id" => 2, "quantity" => 1, "price_at_order" => "50.0" }
      ],
      "timestamp" => "2023-10-27T10:00:00Z"
    }.to_json
  end

  before do
    # Stub RabbitMQ connection for tests
    allow(RABBITMQ_CONNECTION).to receive(:create_channel).and_return(double('channel', topic: double('exchange', publish: true), queue: double('queue', bind: true, subscribe: true, consumer_tag: 'test_consumer')))

    Customer
  end

  describe '.handle_order_created_event' do
    it 'increments the orders_count for the customer' do
      expect {
        OrderCreatedConsumer.send(:handle_order_created_event, JSON.parse(order_created_payload))
      }.to change { customer.reload.orders_count }.by(1)
    end

    it 'does not change orders_count if customer is not found' do
      invalid_payload = JSON.parse(order_created_payload)
      invalid_payload["customer_id"] = 999
      expect {
        OrderCreatedConsumer.send(:handle_order_created_event, invalid_payload)
      }.not_to change { customer.reload.orders_count }
    end

    it 'logs a warning if customer is not found' do
      invalid_payload = JSON.parse(order_created_payload)
      invalid_payload["customer_id"] = 999
      expect(Rails.logger).to receive(:warn).with(/Customer #999 not found/)
      OrderCreatedConsumer.send(:handle_order_created_event, invalid_payload)
    end
  end
end
