class Api::V1::OrdersController < ApplicationController

  def create
    @order = Order.new(order_params)
    @order.status = 'pending'

    if @order.save
      render json: {
        message: "Order created and event published!",
        order: @order,
        customer_details: @order.customer_details
      }, status: :created
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    if params[:customer_id].present?
      @orders = Order.where(customer_id: params[:customer_id])
      render json: @orders
    else
      render json: { error: "customer_id parameter is required" }, status: :bad_request
    end
  end

  private

  def order_params
    params.require(:order).permit(:customer_id, :product_name, :quantity, :price)
  end
end
