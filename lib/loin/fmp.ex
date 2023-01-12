defmodule Loin.FMP do
  @moduledoc """
  The FMP context.
  """
  require Logger

  import Ecto.Query, warn: false
  alias Loin.Repo

  alias Loin.FMP.FMPSecurity

  @doc """
  Returns the list of fmp_securities.

  ## Examples

      iex> list_fmp_securities()
      [%FMPSecurity{}, ...]

  """
  def list_fmp_securities do
    Repo.all(FMPSecurity)
  end

  @doc """
  Gets a single fmp_security.

  Raises `Ecto.NoResultsError` if the FMP security does not exist.

  ## Examples

      iex> get_fmp_security!(123)
      %FMPSecurity{}

      iex> get_fmp_security!(456)
      ** (Ecto.NoResultsError)

  """
  def get_fmp_security!(id), do: Repo.get!(FMPSecurity, id)

  def get_fmp_securities_by_market_cap(limit_number \\ 50) when is_integer(limit_number) do
    FMPSecurity
    |> order_by([s], desc: :market_cap)
    |> limit(^limit_number)
    |> Repo.all()
  end

  @doc """
  Creates a fmp_security.

  ## Examples

      iex> create_fmp_security(%{field: value})
      {:ok, %FMPSecurity{}}

      iex> create_fmp_security(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_fmp_security(attrs \\ %{}) do
    %FMPSecurity{}
    |> FMPSecurity.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a fmp_security.

  ## Examples

      iex> update_fmp_security(fmp_security, %{field: new_value})
      {:ok, %FMPSecurity{}}

      iex> update_fmp_security(fmp_security, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_fmp_security(%FMPSecurity{} = fmp_security, attrs) do
    fmp_security
    |> FMPSecurity.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a fmp_security.

  ## Examples

      iex> delete_fmp_security(fmp_security)
      {:ok, %FMPSecurity{}}

      iex> delete_fmp_security(fmp_security)
      {:error, %Ecto.Changeset{}}

  """
  def delete_fmp_security(%FMPSecurity{} = fmp_security) do
    Repo.delete(fmp_security)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking fmp_security changes.

  ## Examples

      iex> change_fmp_security(fmp_security)
      %Ecto.Changeset{data: %FMPSecurity{}}

  """
  def change_fmp_security(%FMPSecurity{} = fmp_security, attrs \\ %{}) do
    FMPSecurity.changeset(fmp_security, attrs)
  end

  @doc """
  Inserts many FMPSecurity records.
  """
  def insert_many_fmp_securities(entries \\ []) when is_list(entries) do
    {num_affected, nil} =
      Repo.insert_all(FMPSecurity, entries,
        on_conflict: {:replace_all_except, [:id, :inserted_at, :symbol]},
        conflict_target: [:symbol]
      )

    # symbols = Enum.map(entries, &Map.get(&1, :symbol))
    # Logger.info("Saved profiles for #{symbols}")

    {:ok, num_affected}
  end

  def insert_all_profiles(limit \\ 20000) do
    Loin.FMP.Service.all_profiles_stream()
    |> Stream.take(limit)
    |> Stream.chunk_every(10)
    |> Stream.each(&insert_many_fmp_securities/1)
    |> Stream.run()
  end

  alias Loin.FMP.DailyTrend

  @doc """
  Returns the list of daily_trends.

  ## Examples

      iex> list_daily_trends()
      [%DailyTrend{}, ...]

  """
  def list_daily_trends do
    Repo.all(DailyTrend)
  end

  @doc """
  Gets a single daily_trend.

  Raises `Ecto.NoResultsError` if the Daily trend does not exist.

  ## Examples

      iex> get_daily_trend!(123)
      %DailyTrend{}

      iex> get_daily_trend!(456)
      ** (Ecto.NoResultsError)

  """
  def get_daily_trend!(id), do: Repo.get!(DailyTrend, id)

  @doc """
  Creates a daily_trend.

  ## Examples

      iex> create_daily_trend(%{field: value})
      {:ok, %DailyTrend{}}

      iex> create_daily_trend(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_daily_trend(attrs \\ %{}) do
    %DailyTrend{}
    |> DailyTrend.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a daily_trend.

  ## Examples

      iex> update_daily_trend(daily_trend, %{field: new_value})
      {:ok, %DailyTrend{}}

      iex> update_daily_trend(daily_trend, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_daily_trend(%DailyTrend{} = daily_trend, attrs) do
    daily_trend
    |> DailyTrend.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a daily_trend.

  ## Examples

      iex> delete_daily_trend(daily_trend)
      {:ok, %DailyTrend{}}

      iex> delete_daily_trend(daily_trend)
      {:error, %Ecto.Changeset{}}

  """
  def delete_daily_trend(%DailyTrend{} = daily_trend) do
    Repo.delete(daily_trend)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking daily_trend changes.

  ## Examples

      iex> change_daily_trend(daily_trend)
      %Ecto.Changeset{data: %DailyTrend{}}

  """
  def change_daily_trend(%DailyTrend{} = daily_trend, attrs \\ %{}) do
    DailyTrend.changeset(daily_trend, attrs)
  end
end
