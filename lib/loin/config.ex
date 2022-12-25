defmodule Loin.Config do
  @moduledoc """
  Validates and exposes dynamic application configuration.
  """

  @doc """
  Gets the FMP API Key.
  """
  def fmp_api_key() do
    System.fetch_env!("FMP_API_KEY")
  end
end
