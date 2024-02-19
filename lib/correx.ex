defmodule Correx do
  @moduledoc """
  Documentation for `Correx`.
  """

  @doc """
  Calculates freight for given packages for each given service.

  ## Parameters


  ## Examples

      Correx.calculate_freight(%Correx.CalculateFreight.Input{
        service_codes: ["99999"],
        sender_zip_code: "04689160",
        recipient_zip_code: "13563787",
        object_type: Correx.CalculateFreight.object_types().box,
        weight: 1,
        length: 30,
        width: 30,
        height: 30,
        declared_value: 100
      })
      {
        :ok,
        original_response: %Tesla.Env{...},
        %{
          quotes: [
            %Correx.CalculateFreight.FreightQuote{
              declared_value_price: 0.79,
              delivery_time: 1,
              home_delivery: true,
              own_hands_price: 0.0,
              receipt_notification_price: 0.0,
              saturday_delivery: false,
              service_code: "9999",
              total_price: 20.87,
              without_additionals_price: 20.08
            }
          ]
        }
      }
  """
  @spec calculate_freight(Correx.CalculateFreight.Input.t, list) :: Correx.CalculateFreight.result
  def calculate_freight(params, opts \\ []) do
    Correx.CalculateFreight.call(params, opts)
  end
end
