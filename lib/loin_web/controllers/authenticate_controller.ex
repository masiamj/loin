defmodule LoinWeb.AuthenticateController do
  use LoinWeb, :controller

  alias Loin.Accounts.{Identity}

  def delete(conn, _params) do
    LoinWeb.IdentityAuth.log_out_identity(conn)
  end

  def index(conn, _params) do
    conn
    |> assign(:oauth_url, ElixirAuthGoogle.generate_oauth_url(conn))
    |> render(:index)
  end

  def google_callback(conn, %{"code" => code}) do
    {:ok, token} = ElixirAuthGoogle.get_token(code, conn)
    {:ok, profile} = ElixirAuthGoogle.get_user_profile(token.access_token)
    authenticate_or_register(conn, profile)
  end

  # Private
  defp authenticate_or_register(conn, google_profile) do
    case Loin.Accounts.get_identity_by_email(google_profile.email) do
      %Identity{} = existing_identity ->
        LoinWeb.IdentityAuth.log_in_identity(conn, existing_identity)

      nil ->
        {:ok, identity} =
          google_profile
          |> map_google_profile_to_identity()
          |> Loin.Accounts.register_identity()

        LoinWeb.IdentityAuth.log_in_identity(conn, identity)
    end
  end

  defp map_google_profile_to_identity(google_profile) when is_map(google_profile) do
    %{
      email: Map.get(google_profile, :email),
      first_name: Map.get(google_profile, :given_name),
      image_url: Map.get(google_profile, :picture),
      last_name: Map.get(google_profile, :family_name)
    }
  end
end
