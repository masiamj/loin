defmodule Loin.Features do
  @moduledoc """
  Singular place to check feature flags
  """

  def is_anonymous_watchlist_enabled() do
    FunWithFlags.enabled?(:temp_is_anonymous_watchlist_enabled)
  end
end
