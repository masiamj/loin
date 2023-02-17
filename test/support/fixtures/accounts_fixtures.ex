defmodule Loin.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Loin.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Loin.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  @doc """
  Generate a identity.
  """
  def identity_fixture(attrs \\ %{}) do
    {:ok, identity} =
      attrs
      |> Enum.into(%{
        email: "test@example.com",
        first_name: "some first_name",
        image_url: "some image_url",
        last_name: "some last_name"
      })
      |> Loin.Accounts.register_identity()

    identity
  end

  @doc """
  Generate a identity_security.
  """
  # def identity_security_fixture(attrs \\ %{}) do
  #   {:ok, identity_security} =
  #     attrs
  #     |> Enum.into(%{
  #       symbol: "some symbol"
  #     })
  #     |> Loin.Accounts.create_identity_security()

  #   identity_security
  # end
end
