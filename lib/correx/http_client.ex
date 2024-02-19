defmodule Correx.HttpClient do
  @moduledoc false

  @headers [
    {"content-type", "application/x-www-form-urlencoded"}
  ]

  @type retry_options :: [
    max_retries: integer,
    max_delay: integer,
    delay: integer,
    jitter_factor: float,
    should_retry: (-> boolean),
  ]

  def client(opts) do
    middleware = [
      Tesla.Middleware.KeepRequest,
      {Tesla.Middleware.BaseUrl, get_config(:base_url, opts)},
      {Tesla.Middleware.Headers, @headers},
      {Tesla.Middleware.Retry, retry_opts(opts)},
      Correx.ErrorMiddleware
    ]

    Tesla.client(middleware)
  end

  def ncd_empresa(opts \\ []) do
    get_config(:administrative_code, opts)
  end

  def sds_senha(opts \\ []) do
    get_config(:sigep_password, opts)
  end

  defp retry_opts(opts) do
    default = [
      max_retries: 5,
      max_delay: 2000,
      should_retry: fn
        {:error, _} -> true
        {:ok, %{status: status}} when status in [408] -> true
        # {:ok, response} ->
        #   String.contains?(
        #     response.body,
        #     "Data or method not found. Status code 404"
        #   )
        _ -> false
      end
    ]

    default
    |> Keyword.merge(Application.get_env(:correx, :retry) || [])
    |> Keyword.merge(opts[:retry] || [])
  end

  @defaults [
    base_url: "https://ws.correios.com.br"
  ]
  defp get_config(config_name, opts) do
    env_var_name =
      config_name
      |> Atom.to_string()
      |> String.upcase()

    Keyword.get(opts, config_name) ||
      Application.get_env(:correx, config_name) ||
      System.get_env(env_var_name) ||
      Keyword.get(@defaults, config_name) ||
      raise RuntimeError, """
      The required "#{config_name}" config isn't defined anywhere.
      You can define it by:
        - Setting `config :correx, #{config_name}: "my_value"` in your config.ex
        - Defiing an env var called CORREX_#{env_var_name}
        - Passing `#{config_name}: "my_value"` as an option to method called.
      """
  end
end
