class ProductAvailabilityChannel < ApplicationCable::Channel
  def subscribed
    stream_from "product_availability"
  end
end

