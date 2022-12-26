defmodule Loin.FMP.MajorIndexSymbolsCache do
  @moduledoc """
  Caches symbols for checking in the major indices.
  """
  use GenServer
  alias Loin.FMP.Service

  # Callbacks

  @doc """
  Starts the GenServer.
  """
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Checks if a symbol is in the Dow Jones.
  """
  def is_dow_jones(symbol) when is_binary(symbol) do
    GenServer.call(__MODULE__, {:is_dow_jones, symbol})
  end

  @doc """
  Checks if a symbol is in the Nasdaw.
  """
  def is_nasdaq(symbol) when is_binary(symbol) do
    GenServer.call(__MODULE__, {:is_nasdaq, symbol})
  end

  @doc """
  Checks if a symbol is in the S&P 500.
  """
  def is_sp500(symbol) when is_binary(symbol) do
    GenServer.call(__MODULE__, {:is_sp500, symbol})
  end

  # Server

  @impl true
  def init(_opts) do
    {:ok,
     %{
       dow_jones_symbols: MapSet.new(),
       nasdaq_symbols: MapSet.new(),
       sp500_symbols: MapSet.new()
     }, {:continue, :initialize}}
  end

  @impl true
  def handle_call({:is_dow_jones, symbol}, _from, %{dow_jones_symbols: symbols} = state) do
    {:reply, MapSet.member?(symbols, symbol), state}
  end

  @impl true
  def handle_call({:is_nasdaq, symbol}, _from, %{nasdaq_symbols: symbols} = state) do
    {:reply, MapSet.member?(symbols, symbol), state}
  end

  @impl true
  def handle_call({:is_sp500, symbol}, _from, %{sp500_symbols: symbols} = state) do
    {:reply, MapSet.member?(symbols, symbol), state}
  end

  @impl true
  def handle_continue(:initialize, _state) do
    [dow_jones_symbols, nasdaq_symbols, sp500_symbols] =
      [
        Task.async(fn -> Service.dow_jones_companies_symbols() end),
        Task.async(fn -> Service.nasdaq_companies_symbols() end),
        Task.async(fn -> Service.sp500_companies_symbols() end)
      ]
      |> Task.await_many()

    state = %{
      dow_jones_symbols: dow_jones_symbols,
      nasdaq_symbols: nasdaq_symbols,
      sp500_symbols: sp500_symbols
    }

    {:noreply, state}
  end
end
