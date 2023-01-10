defmodule Loin.FMP do
  @moduledoc """
  The FMP context.
  """

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

  Raises `Ecto.NoResultsError` if the Fmp security does not exist.

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

    {:ok, num_affected}
  end

  def insert_all_profiles(num) do
    Loin.FMP.Service.all_profiles_stream()
    |> Stream.take(num)
    |> Stream.chunk_every(10)
    |> Stream.each(&insert_many_fmp_securities/1)
    |> Stream.run()
  end
end
