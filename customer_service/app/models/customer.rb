class Customer < ApplicationRecord
  validates :name, presence: true
  validates :address, presence: true
  validates :orders_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  after_initialize :set_default_orders_count, if: :new_record?

  private

  def set_default_orders_count
    self.orders_count ||= 0
  end
end
