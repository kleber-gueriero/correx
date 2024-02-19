defmodule Correx.CalculateFreightTest do
  use ExUnit.Case, async: true

  alias Correx.{
    CalculateFreight,
    CalculateFreight.FreightQuote,
    HttpClient
  }

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  @path "/calculador/CalcPrecoPrazo.asmx/CalcPrecoPrazo"
  @fixtures_path "test/calculate_freight/fixtures"
  @success_response File.read!("#{@fixtures_path}/success_response.xml")
  @valid_input %CalculateFreight.Input{
    services: [
      %{code: "99999", name: "SEDEX"}
    ],
    sender_zip_code: "04689160",
    recipient_zip_code: "13563787",
    object_type: CalculateFreight.object_types().box,
    weight: 1,
    length: 30,
    width: 30,
    height: 30,
    declared_value: 100
  }

  describe "call WHEN parameters are valid" do
    test "makes API request to Correios calculate freight and deadline endpoint", %{
      bypass: bypass
    } do
      Bypass.expect_once(bypass, "POST", @path, fn conn ->
        {:ok, req_body, _} = Plug.Conn.read_body(conn)

        expected_body =
          "nCdEmpresa=99999999&sDsSenha=999999&nCdServico=99999&sCepOrigem=04689160&sCepDestino=13563787&nVlPeso=1&nCdFormato=1&nVlComprimento=30&nVlAltura=30&nVlLargura=30&nVlDiametro=0&sCdMaoPropria=N&nVlValorDeclarado=100&sCdAvisoRecebimento=N"

        assert req_body == expected_body

        assert Enum.member?(
                 conn.req_headers,
                 {"content-type", "application/x-www-form-urlencoded"}
               )

        Plug.Conn.send_resp(conn, 200, @success_response)
      end)

      {:ok, result} = CalculateFreight.call(@valid_input, base_url: endpoint_url(bypass.port))
    end

    test "returns formatted ouput", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", @path, fn conn ->
        Plug.Conn.send_resp(conn, 200, @success_response)
      end)

      {:ok, result} = CalculateFreight.call(@valid_input, base_url: endpoint_url(bypass.port))

      assert result.quotes == [
         %FreightQuote{
           service: %{code: "99999", name: "SEDEX"},
           total_price: 20.87,
           delivery_time: 1,
           without_additionals_price: 20.08,
           own_hands_price: 0.0,
           receipt_notification_price: 0.0,
           declared_value_price: 0.79,
           home_delivery: true,
           saturday_delivery: false
         }
       ]
    end

    test "retries in case of \":econnrefused\"", %{bypass: bypass} do
      Bypass.expect(bypass, "POST", @path, fn conn ->
        Plug.Conn.send_resp(conn, 200, @success_response)
      end)

      Task.async(fn ->
        Bypass.down(bypass)
        Process.sleep(100)
        Bypass.up(bypass)
      end)

      {:ok, result} =
        CalculateFreight.call(
          @valid_input,
          base_url: endpoint_url(bypass.port),
          retry: [max_retries: 2, max_delay: 100]
        )
    end

    test "returns error when fails even after all retries", %{bypass: bypass} do
      Bypass.stub(bypass, "POST", @path, fn conn ->
        Plug.Conn.send_resp(conn, 200, @success_response)
      end)

      Task.async(fn ->
        Bypass.down(bypass)
        Process.sleep(100)
        Bypass.up(bypass)
      end)

      {:error, :econnrefused} =
        CalculateFreight.call(
          @valid_input,
          base_url: endpoint_url(bypass.port),
          retry: [max_retries: 1, max_delay: 100]
        )
    end
  end

  describe "call WHEN fails" do
  end

  defp endpoint_url(port), do: "http://localhost:#{port}/"
end
