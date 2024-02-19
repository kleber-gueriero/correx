defmodule Correx.CalculateFreight.FreightQuote do
  @moduledoc false
  @type t :: %__MODULE__{
    total_price: float(),
  }
  @enforce_keys []
  defstruct [
    :service,
    :total_price,
    :delivery_time,
    :without_additionals_price,
    :own_hands_price,
    :receipt_notification_price,
    :declared_value_price,
    :home_delivery,
    :saturday_delivery,
    # fields copied from input
    :sender_zip_code,
    :recipient_zip_code,
    :object_type,
    :weight,
    :length,
    :width,
    :height,
    :declared_value
  ]

  def build(api_response, freight_input) do
    %Correx.CalculateFreight.FreightQuote{
      service: Enum.find(freight_input.services, fn i ->
        i.code == String.pad_leading(api_response.service_code, 5, "0")
      end),
      total_price: String.to_float(api_response.total_price),
      delivery_time: String.to_integer(api_response.delivery_time),
      without_additionals_price: String.to_float(api_response.without_additionals_price),
      own_hands_price: String.to_float(api_response.own_hands_price),
      receipt_notification_price: String.to_float(api_response.receipt_notification_price),
      declared_value_price: String.to_float(api_response.declared_value_price),
      home_delivery: extract_home_delivery(api_response),
      saturday_delivery: extract_saturday_delivery(api_response),
      # fields copied from input
      sender_zip_code:  freight_input.sender_zip_code,
      recipient_zip_code:  freight_input.recipient_zip_code,
      object_type:  freight_input.object_type,
      weight:  freight_input.weight,
      length:  freight_input.length,
      width:  freight_input.width,
      height:  freight_input.height,
      declared_value:  freight_input.declared_value
    }
  end

  defp extract_home_delivery(attrs) do
    if attrs.home_delivery == "S", do: true, else: false
  end

  defp extract_saturday_delivery(attrs) do
    if attrs.saturday_delivery == "S", do: true, else: false
  end
end
