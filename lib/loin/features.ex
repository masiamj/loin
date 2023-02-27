defmodule Loin.Features do
  @moduledoc """
  Singular place to check feature flags
  """

  @market_schedule %OpenHours.Schedule{
    hours: %{
      mon: [{~T[06:00:00], ~T[18:00:00]}],
      tue: [{~T[06:00:00], ~T[18:00:00]}],
      wed: [{~T[06:00:00], ~T[18:00:00]}],
      thu: [{~T[06:00:00], ~T[18:00:00]}],
      fri: [{~T[06:00:00], ~T[18:00:00]}]
    },
    time_zone: "America/New_York"
  }

  def is_realtime_quotes_enabled() do
    FunWithFlags.enabled?(:realtime_quotes) && is_in_possible_market_hours?()
  end

  defp is_in_possible_market_hours?() do
    current_time = Timex.now("America/New_York")
    OpenHours.Schedule.in_hours?(@market_schedule, current_time)
  end
end
