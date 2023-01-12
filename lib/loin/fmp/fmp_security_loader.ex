defmodule Loin.FMP.FMPSecurityLoader do
  @moduledoc """
  Ensures profiles are always loaded in the app.
  """
  use GenServer

  # Callbacks

  @doc """
  Starts the GenServer.
  """
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Seeds the profiles into the DB.

  This command is meant to be run manually as a dev chore.
  """
  def seed() do
    GenServer.call(__MODULE__, {:seed}, 90_000)
  end

  @doc """
  Gets the process state.
  """
  def state() do
    GenServer.call(__MODULE__, {:state})
  end

  # Server

  @impl true
  def init(_opts) do
    {:ok, %{last_checked: nil, seeded: false}, {:continue, :initialize}}
  end

  @impl true
  def handle_call({:seed}, _from, state) do
    :ok = Loin.FMP.insert_all_profiles(16_000)

    state =
      state
      |> Map.put(:last_checked, DateTime.utc_now())
      |> Map.put(:seeded, true)

    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:state}, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_continue(:initialize, state) do
    case has_fmp_securities?() do
      true ->
        state =
          state
          |> Map.put(:last_checked, DateTime.utc_now())
          |> Map.put(:seeded, true)

        {:noreply, state}

      false ->
        :ok = Loin.FMP.insert_all_profiles(100)

        state =
          state
          |> Map.put(:last_checked, DateTime.utc_now())
          |> Map.put(:seeded, true)

        {:noreply, state}
    end
  end

  defp has_fmp_securities? do
    count = Loin.FMP.count_fmp_securities()
    count > 0
  end
end
