defmodule LoinWeb.AuthenticateController do
  use LoinWeb, :controller

  def index(conn, _params) do
    conn
    |> assign(:oauth_url, ElixirAuthGoogle.generate_oauth_url(conn))
    |> render(:index)
  end

  def google_callback(conn, %{"code" => code}) do
    {:ok, token} = ElixirAuthGoogle.get_token(code, conn)
    {:ok, profile} = ElixirAuthGoogle.get_user_profile(token.access_token)
    IO.inspect(profile, label: "Profile")

    redirect(conn, to: "/")
  end
end
