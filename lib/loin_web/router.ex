defmodule LoinWeb.Router do
  use LoinWeb, :router

  import LoinWeb.UserAuth
  import Plug.BasicAuth

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LoinWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :developers do
    plug :basic_auth, username: "loincloth", password: "trending"
  end

  # Developers-only section
  import Phoenix.LiveDashboard.Router
  import Oban.Web.Router

  scope "/dev" do
    # use Kaffy.Routes, scope: "/admin", pipe_through: [:browser, :developers]

    pipe_through [:browser, :developers]
    use Kaffy.Routes, scope: "/admin"
    # Admin portal
    # Phoenix LiveDashboard
    live_dashboard "/dashboard", metrics: LoinWeb.Telemetry
    # Oban web dashboard
    oban_dashboard("/jobs")
    # Email viewer
    forward "/mailbox", Plug.Swoosh.MailboxPreview
  end

  # Routes for FunWithFlagsUI: https://github.com/tompave/fun_with_flags_ui
  scope path: "/feature-flags" do
    pipe_through [:browser, :developers]
    forward "/", FunWithFlags.UI.Router, namespace: "feature-flags"
  end

  ## Authentication routes
  scope "/", LoinWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{LoinWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/", HomeLive, :home
      live "/s/:symbol", SecurityLive, :show
      live "/screener", ScreenerLive, :index
      live "/how-it-works", HowItWorksLive, :index
      live "/users/log_in", UserLoginLive, :new
      live "/users/register", UserRegistrationLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", LoinWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{LoinWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", LoinWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{LoinWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
