defmodule Correx.CalculateFreight.Input do
  @moduledoc false
  @type service :: %{code: String.t(), name: String.t()}
  @type t :: %__MODULE__{
          services: list(service()),
          sender_zip_code: String.t(),
          recipient_zip_code: String.t()
          # object_type: Correx.CalculateFreight.object_types,
        }
  @enforce_keys [
    :services,
    :sender_zip_code,
    :recipient_zip_code,
    :object_type,
    :weight,
    :length,
    :height,
    :width
  ]
  defstruct [
    :services,
    :sender_zip_code,
    :recipient_zip_code,
    :object_type,
    :weight,
    :length,
    :height,
    :width,
    diameter: 0,
    own_hands: "N",
    declared_value: 0,
    receipt_notification: "N"
  ]
end
