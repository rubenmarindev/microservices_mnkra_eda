# Microservices EDA + HTTP Example

This project demonstrates a microservices architecture with two Ruby on Rails services:

- **OrderService:** Manages customer orders.
- **CustomerService:** Manages customer information.

It showcases both synchronous HTTP communication (OrderService fetching customer details from CustomerService) and asynchronous event-driven communication (OrderService publishing events to RabbitMQ, CustomerService consuming them to update order counts).

## Architecture Overview


## Setup and Installation

1.  **Clone the repository:**
    ```bash
    git clone git@github.com:rubenmarindev/microservices_mnkra_eda.git
    cd microservices_mnkra_eda
    ```

2.  **Start Docker Compose services (RabbitMQ and PostgreSQL):**
    Ensure Docker is running on your machine.
    ```bash
    docker-compose up -d
    ```
    This will start `rabbitmq` on ports 5672/15672, `orders_db` on 5432, and `customer_db` on 5433.

3.  **Install Gems for each service:**

    ```bash
    cd orders_service
    bundle install
    cd ../customer_service
    bundle install
    cd .. # Go back to root directory
    ```

4.  **Prepare Databases:**
    Create, migrate, and seed the databases for both services.

    ```bash
    cd orders_service
    bin/rails db:create db:migrate
    cd ../customer_service
    bin/rails db:create db:migrate db:seed # Seeds pre-defined customers
    cd ..
    ```

## Running the Services

Use `foreman` (via `bin/dev`) to run all services concurrently in development mode.

```bash
bin/dev
```

## Running Tests

```bash
# In microservices_mnkra_eda/orders_service
bundle exec rspec

# In microservices_mnkra_eda/customer_service
bundle exec rspec
```