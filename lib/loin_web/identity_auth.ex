defmodule LoinWeb.IdentityAuth do
  @moduledoc """
  Adds utility functions and plugs for identity authentication.
  """

  use LoinWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Loin.Accounts

  # Make the remember me cookie valid for 60 days.
  # If you want bump or reduce this value, also change
  # the token expiry itself in IdentityToken.
  @max_age 60 * 60 * 24 * 60
  @remember_me_cookie "_loin_web_identity_remember_me"
  @remember_me_options [sign: true, max_age: @max_age, same_site: "Lax"]

  @doc """
  Logs the identity in.

  It renews the session ID and clears the whole session
  to avoid fixation attacks. See the renew_session
  function to customize this behaviour.

  It also sets a `:live_socket_id` key in the session,
  so LiveView sessions are identified and automatically
  disconnected on log out. The line can be safely removed
  if you are not using LiveView.
  """
  def log_in_identity(conn, identity, params \\ %{}) do
    token = Accounts.generate_identity_session_token(identity)
    user_return_to = get_session(conn, :user_return_to)

    conn
    |> renew_session()
    |> put_token_in_session(token)
    |> maybe_write_remember_me_cookie(token, params)
    |> redirect(to: user_return_to || signed_in_path(conn))
  end

  defp maybe_write_remember_me_cookie(conn, token, %{"remember_me" => "true"}) do
    put_resp_cookie(conn, @remember_me_cookie, token, @remember_me_options)
  end

  defp maybe_write_remember_me_cookie(conn, _token, _params) do
    conn
  end

  # This function renews the session ID and erases the whole
  # session to avoid fixation attacks. If there is any data
  # in the session you may want to preserve after log in/log out,
  # you must explicitly fetch the session data before clearing
  # and then immediately set it after clearing, for example:
  #
  #     defp renew_session(conn) do
  #       preferred_locale = get_session(conn, :preferred_locale)
  #
  #       conn
  #       |> configure_session(renew: true)
  #       |> clear_session()
  #       |> put_session(:preferred_locale, preferred_locale)
  #     end
  #
  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  @doc """
  Logs the identity out.

  It clears all session data for safety. See renew_session.
  """
  def log_out_identity(conn) do
    identity_token = get_session(conn, :identity_token)
    identity_token && Accounts.delete_identity_session_token(identity_token)

    if live_socket_id = get_session(conn, :live_socket_id) do
      LoinWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie)
    |> redirect(to: "/")
  end

  @doc """
  Authenticates the identity by looking into the session
  and remember me token.
  """
  def fetch_current_identity(conn, _opts) do
    {identity_token, conn} = ensure_identity_token(conn)
    identity = identity_token && Accounts.get_identity_by_session_token(identity_token)
    assign(conn, :current_identity, identity)
  end

  defp ensure_identity_token(conn) do
    if token = get_session(conn, :identity_token) do
      {token, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if token = conn.cookies[@remember_me_cookie] do
        {token, put_token_in_session(conn, token)}
      else
        {nil, conn}
      end
    end
  end

  @doc """
  Handles mounting and authenticating the current_identity in LiveViews.

  ## `on_mount` arguments

    * `:mount_current_identity` - Assigns current_identity
      to socket assigns based on identity_token, or nil if
      there's no identity_token or no matching identity.

    * `:ensure_authenticated` - Authenticates the identity from the session,
      and assigns the current_identity to socket assigns based
      on identity_token.
      Redirects to login page if there's no logged identity.

    * `:redirect_if_identity_is_authenticated` - Authenticates the identity from the session.
      Redirects to signed_in_path if there's a logged identity.

  ## Examples

  Use the `on_mount` lifecycle macro in LiveViews to mount or authenticate
  the current_identity:

      defmodule LoinWeb.PageLive do
        use LoinWeb, :live_view

        on_mount {LoinWeb.IdentityAuth, :mount_current_identity}
        ...
      end

  Or use the `live_session` of your router to invoke the on_mount callback:

      live_session :authenticated, on_mount: [{LoinWeb.IdentityAuth, :ensure_authenticated}] do
        live "/profile", ProfileLive, :index
      end
  """
  def on_mount(:mount_current_identity, _params, session, socket) do
    {:cont, mount_current_identity(session, socket)}
  end

  def on_mount(:ensure_authenticated, _params, session, socket) do
    socket = mount_current_identity(session, socket)

    if socket.assigns.current_identity do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You must log in to access this page.")
        |> Phoenix.LiveView.redirect(to: ~p"/auth")

      {:halt, socket}
    end
  end

  def on_mount(:redirect_if_identity_is_authenticated, _params, session, socket) do
    socket = mount_current_identity(session, socket)

    if socket.assigns.current_identity do
      {:halt, Phoenix.LiveView.redirect(socket, to: signed_in_path(socket))}
    else
      {:cont, socket}
    end
  end

  defp mount_current_identity(session, socket) do
    case session do
      %{"identity_token" => identity_token} ->
        Phoenix.Component.assign_new(socket, :current_identity, fn ->
          Accounts.get_identity_by_session_token(identity_token)
        end)

      %{} ->
        Phoenix.Component.assign_new(socket, :current_identity, fn -> nil end)
    end
  end

  @doc """
  Used for routes that require the identity to not be authenticated.
  """
  def redirect_if_identity_is_authenticated(conn, _opts) do
    if conn.assigns[:current_identity] do
      conn
      |> redirect(to: signed_in_path(conn))
      |> halt()
    else
      conn
    end
  end

  @doc """
  Used for routes that require the identity to be authenticated.

  If you want to enforce the identity email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_identity(conn, _opts) do
    if conn.assigns[:current_identity] do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> maybe_store_return_to()
      |> redirect(to: ~p"/auth")
      |> halt()
    end
  end

  defp put_token_in_session(conn, token) do
    conn
    |> put_session(:identity_token, token)
    |> put_session(:live_socket_id, "identities_sessions:#{Base.url_encode64(token)}")
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :user_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn

  defp signed_in_path(_conn), do: ~p"/"
end
