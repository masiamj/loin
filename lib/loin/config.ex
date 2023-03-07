defmodule Loin.Config do
  @moduledoc """
  Validates and exposes dynamic application configuration.
  """
  require Logger

  @appsignal_push_api_key "APPSIGNAL_PUSH_API_KEY"
  @fmp_api_key_env_var "FMP_API_KEY"

  @doc """
  Gets the FMP API Key.
  """
  def fmp_api_key() do
    System.fetch_env!(@fmp_api_key_env_var)
  end

  @doc """
  Checks for any missing environment variables, throws on invalid configuration.
  """
  def validate!() do
    missing_environment_vars =
      [
        @appsignal_push_api_key,
        @fmp_api_key_env_var
      ]
      |> Enum.reduce([], fn key, acc ->
        case System.get_env(key) do
          nil -> [key | acc]
          _ -> acc
        end
      end)

    case length(missing_environment_vars) do
      0 ->
        :ok

      _ ->
        raise RuntimeError,
          message:
            "Invalid environment configuration, missing variables: #{Enum.join(missing_environment_vars, ", ")}"
    end
  end
end
