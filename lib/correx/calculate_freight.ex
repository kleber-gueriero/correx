defmodule Correx.CalculateFreight do
  @moduledoc false
  import SweetXml

  alias Correx.{
    CalculateFreight,
    HttpClient
  }

  # @type options :: [
  #   base_url: String.t,
  #   administrative_code: String.t,
  #   sigep_password: String.t,
  #   retry: HttpClient.retry_options,
  # ]
  @type result :: {:ok, [CalculateFreight.FreightQuote.t]} | {:error, any}

  @spec call(%Correx.CalculateFreight.Input{}, list) :: result
  def call(params, opts \\ []) do
    with {:ok, response} <- call_api(params, opts),
         do: format_output(response, params)
  end

  @object_types %{
    box: :box,
    envelope: :envelope,
    tube: :tube
  }
  def object_types, do: @object_types

  defp call_api(params, opts) do
    Tesla.post(
      HttpClient.client(opts),
      "/calculador/CalcPrecoPrazo.asmx/CalcPrecoPrazo",
      build_body(params)
    )
  end

  defp build_body(params) do
    [
      "nCdEmpresa=#{HttpClient.ncd_empresa()}",
      "sDsSenha=#{HttpClient.sds_senha()}",
      "nCdServico=#{ncd_servico(params)}",
      "sCepOrigem=#{params.sender_zip_code}",
      "sCepDestino=#{params.recipient_zip_code}",
      "nVlPeso=#{params.weight}",
      "nCdFormato=#{get_object_type_code(params.object_type)}",
      "nVlComprimento=#{params.length}",
      "nVlAltura=#{params.height}",
      "nVlLargura=#{params.width}",
      "nVlDiametro=#{params.diameter}",
      "sCdMaoPropria=#{params.own_hands}",
      "nVlValorDeclarado=#{params.declared_value}",
      "sCdAvisoRecebimento=#{params.receipt_notification}"
    ]
    |> Enum.join("&")
  end

  defp format_output(response, params) do
    formatted_output =
      response.body
      |> xpath(
        ~x"//Servicos/cServico"l,
        service_code: ~x"./Codigo/text()"s,
        total_price: ~x"./Valor/text()"s,
        delivery_time: ~x"./PrazoEntrega/text()"s,
        without_additionals_price: ~x"./ValorSemAdicionais/text()"s,
        own_hands_price: ~x"./ValorMaoPropria/text()"s,
        receipt_notification_price: ~x"./ValorAvisoRecebimento/text()"s,
        declared_value_price: ~x"./ValorValorDeclarado/text()"s,
        home_delivery: ~x"./EntregaDomiciliar/text()"s,
        saturday_delivery: ~x"./EntregaSabado/text()"s
      )
      |> Enum.map(fn i -> CalculateFreight.FreightQuote.build(i, params) end)

    {:ok, formatted_output}
  end

  @object_type_codes %{
    box: "1",
    tube: "2",
    envelope: "3"
  }
  defp get_object_type_code(object_type) do
    @object_type_codes[object_type]
  end

  defp ncd_servico(params) do
    params.services
    |> Enum.map(fn i -> i.code end)
    |> Enum.join(",")
  end
end
