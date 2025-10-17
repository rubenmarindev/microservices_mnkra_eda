# orders_service/app/models/order.rb
class Order < ApplicationRecord
  validates :customer_id, presence: true
  validates :product_name, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true

  validate :customer_exists_in_customer_service, on: :create

  after_create_commit :publish_order_created_event

  attr_accessor :customer_details

  private

  def customer_exists_in_customer_service
    @customer_details = CustomerApiClient.fetch_customer_details(customer_id)
    unless @customer_details
      errors.add(:customer_id, "does not exist or CustomerService is unreachable")
    end
  rescue Faraday::ConnectionFailed, Faraday::TimeoutError
    errors.add(:customer_id, "does not exist or CustomerService is unreachable")
  end

  def publish_order_created_event
    EventPublishers::OrderPublisher.publish_created(self)
  end
end
