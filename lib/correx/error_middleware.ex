defmodule Correx.ErrorMiddleware do
  @moduledoc false
  @behaviour Tesla.Middleware

  def call(env, next, _) do
    env
    |> Tesla.run(next)
    |> handle_status()
  end

  def handle_status({:error, error}), do: {:error, error}
  def handle_status({:ok, response = %{status: status}}) when status < 400, do: {:ok, response}

  def handle_status({:ok, response}) do
    {:error, response}
  end
end
