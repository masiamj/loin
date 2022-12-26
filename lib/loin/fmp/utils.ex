defmodule Loin.FMP.Utils do
  @moduledoc """
  A set of helper functions for dealing with data from FMP.
  """

  @doc """
  Creates indicators.
  """
  def create_indicators(%{symbol: symbol, data: chronological_data})
      when is_list(chronological_data) do
    # Extract prices to run indicator calculations
    [day_200_smas, day_50_smas] =
      chronological_data
      |> Enum.map(&Map.get(&1, :close))
      |> calculate_smas()

    # Calculate flags
    data_with_indicators =
      [chronological_data, day_200_smas, day_50_smas]
      |> Enum.zip_with(fn [%{close: close} = item, day_200_sma, day_50_sma] ->
        Map.merge(
          item,
          calculate_flags(%{
            close: close,
            day_200_sma: day_200_sma,
            day_50_sma: day_50_sma
          })
        )
      end)
      |> Enum.reverse()
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(&append_previous_flags_to_current/1)

    %{data: data_with_indicators, symbol: symbol}
  end

  @doc """
  Verifies a security is US-based and in USD
  """
  def is_us_security(%{"country" => country, "currency" => currency}) do
    case {country, currency} do
      {"US", "USD"} -> true
      _ -> false
    end
  end

  @doc """
  Maps a list of items with a transform in a concurrent way.
  """
  def map(items, transform) when is_list(items) do
    items
    |> Flow.from_enumerable()
    |> Flow.partition()
    |> Flow.map(fn item -> transform.(item) end)
    |> Enum.to_list()
  end

  # Private functions

  defp append_previous_flags_to_current([previous, current]) do
    Map.merge(current, %{
      previous_close: Map.get(previous, :close),
      previous_day_200_sma: Map.get(previous, :day_200_sma),
      previous_day_50_sma: Map.get(previous, :day_50_sma),
      previous_close_above_day_200_sma: Map.get(previous, :close_above_day_200_sma),
      previous_close_above_day_50_sma: Map.get(previous, :close_above_day_50_sma),
      previous_day_50_sma_above_day_200_sma: Map.get(previous, :day_50_sma_above_day_200_sma),
      previous_trend: Map.get(previous, :trend),
      previous_truthy_flags_count: Map.get(previous, :truthy_flags_count),
      trend_change: calculate_trend_change(Map.get(previous, :trend), Map.get(current, :trend))
    })
  end

  defp calculate_flags(%{day_200_sma: day_200_sma, day_50_sma: day_50_sma})
       when is_nil(day_200_sma) or is_nil(day_50_sma) do
    %{
      close_above_day_200_sma: false,
      close_above_day_50_sma: false,
      day_50_sma_above_day_200_sma: false,
      is_valid: false,
      trend: nil,
      truthy_flags_count: 0
    }
  end

  defp calculate_flags(%{close: close, day_200_sma: day_200_sma, day_50_sma: day_50_sma})
       when is_number(day_200_sma) and is_number(day_50_sma) do
    flags = %{
      close_above_day_200_sma: close > day_200_sma,
      close_above_day_50_sma: close > day_50_sma,
      day_50_sma_above_day_200_sma: day_50_sma > day_200_sma
    }

    truthy_flags_count = count_truthy_flags(flags)

    trend =
      case truthy_flags_count do
        0 -> :down
        1 -> :down
        2 -> :neutral
        3 -> :up
      end

    Map.merge(flags, %{
      day_200_sma: day_200_sma,
      day_50_sma: day_50_sma,
      is_valid: true,
      trend: trend,
      truthy_flags_count: truthy_flags_count
    })
  end

  defp calculate_smas(chronological_data) when is_list(chronological_data) do
    desired_list_length = length(chronological_data)

    task_day_200_sma =
      Task.async(fn ->
        Indicado.SMA.eval!(chronological_data, 200)
        |> pad_list_with_nils(desired_list_length)
      end)

    task_day_50_sma =
      Task.async(fn ->
        Indicado.SMA.eval!(chronological_data, 50)
        |> pad_list_with_nils(desired_list_length)
      end)

    Task.await_many([task_day_200_sma, task_day_50_sma])
  end

  defp calculate_trend_change(previous_trend, current_trend) do
    case {previous_trend, current_trend} do
      {nil, _} -> nil
      {_, nil} -> nil
      {:down, :down} -> nil
      {:down, :neutral} -> :down_to_neutral
      {:down, :up} -> :down_to_up
      {:neutral, :down} -> :neutral_to_down
      {:neutral, :neutral} -> nil
      {:neutral, :up} -> :neutral_to_up
      {:up, :down} -> :up_to_down
      {:up, :neutral} -> :up_to_neutral
      {:up, :up} -> nil
    end
  end

  defp count_truthy_flags(flags) do
    flags
    |> Map.values()
    |> Enum.map(fn item ->
      case item do
        true -> 1
        false -> 0
      end
    end)
    |> Enum.sum()
  end

  defp pad_list_with_nils(list_to_pad, desired_length) when is_list(list_to_pad) do
    List.duplicate(nil, desired_length - length(list_to_pad))
    |> then(fn padding -> [padding | list_to_pad] end)
    |> List.flatten()
  end
end
