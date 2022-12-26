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
end
