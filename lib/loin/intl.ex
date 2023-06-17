defmodule Loin.Intl do
  @moduledoc """
  A module to call for CLDR-related functions.
  See: https://github.com/elixir-cldr/cldr
  """
  use Cldr,
    locales: ["en"],
    default_locale: "en",
    providers: [Cldr.Number]

  @doc """
  Formats a date represented as a string.
  """
  def format_date(date_string) do
    case date_string do
      value when value in [nil, ""] ->
        "-"

      value ->
        value
        |> Timex.parse!("%Y-%m-%d", :strftime)
        |> Timex.format!("%b %d, %Y", :strftime)
    end
  end

  @doc """
  Formats a date with time in EST.
  """
  def format_datetime_est(datetime_utc) do
    est_value =
      datetime_utc
      |> DateTime.shift_zone!("America/New_York")
      |> Timex.format!("%a. %b. %d, %Y %l:%M:%S", :strftime)

    est_value <> " EST"
  end

  @doc """
  Formats money in decimal form. 13.2342342 -> 13.23
  """
  def format_decimal(value) do
    case value do
      nil -> "-"
      value -> __MODULE__.Number.to_string!(value, fractional_digits: 2)
    end
  end

  @doc """
  Formats a value in decimal form without fractional digits
  """
  def format_decimal(value, :short) do
    case value do
      nil -> "-"
      value -> __MODULE__.Number.to_string!(value, format: :short, fractional_digits: 0)
    end
  end

  @doc """
  Formats money in decimal form. 13.2342342 -> $13.23
  """
  def format_money_decimal(value) when is_number(value) and value > 100_000 do
    __MODULE__.Number.to_string!(value, format: :short, currency: "USD", fractional_digits: 2)
  end

  def format_money_decimal(value) do
    case value do
      nil -> "-"
      value -> __MODULE__.Number.to_string!(value, currency: "USD")
    end
  end

  @doc """
  Formats a number as a percentage.
  """
  def format_percent(value) do
    case value do
      nil ->
        "-"

      value ->
        __MODULE__.Number.to_string!(value / 100, format: :percent, fractional_digits: 2)
    end
  end

  @doc """
  Formats a number as a percentage, already in decimal form.
  """
  def format_percent_from_decimal(value) do
    case value do
      nil ->
        "-"

      value ->
        __MODULE__.Number.to_string!(value, format: :percent, fractional_digits: 2)
    end
  end
end
