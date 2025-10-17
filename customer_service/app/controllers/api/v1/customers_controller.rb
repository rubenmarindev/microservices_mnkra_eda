class Api::V1::CustomersController < ApplicationController

  def show
    @customer = Customer.find_by(id: params[:id])

    if @customer
      render json: {
        customer_id: @customer.id,
        customer_name: @customer.name,
        address: @customer.address,
        orders_count: @customer.orders_count || 0
      }
    else
      render json: { error: "Customer not found" }, status: :not_found
    end
  end
end
