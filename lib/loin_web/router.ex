defmodule LoinWeb.Router do
  use LoinWeb, :router

  import LoinWeb.UserAuth
  import Plug.BasicAuth

  pipeline :browser do
    plug :accepts, ["html"]
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

  pipeline :api do
    plug :accepts, ["json"]
  end

  # scope "/", LoinWeb do
  #   pipe_through :browser

  #   get "/", PageController, :home
  # end

  # Other scopes may use custom stacks.
  # scope "/api", LoinWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:loin, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:browser, :developers]

      live_dashboard "/dashboard", metrics: LoinWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end

    # Routes for FunWithFlagsUI: https://github.com/tompave/fun_with_flags_ui
    scope path: "/feature-flags" do
      pipe_through [:browser, :developers]

      forward "/", FunWithFlags.UI.Router, namespace: "feature-flags"
    end
  end

  ## Authentication routes

  scope "/", LoinWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{LoinWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
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

  scope "/", LoinWeb do
    pipe_through [:browser]

    live "/", HomeLive, :home
    live "/:symbol", SecurityLive, :show
    live "/fmp_securities", FMPSecurityLive.Index, :index
    live "/fmp_securities/new", FMPSecurityLive.Index, :new
    live "/fmp_securities/:id/edit", FMPSecurityLive.Index, :edit
    live "/fmp_securities/:id", FMPSecurityLive.Show, :show
    live "/fmp_securities/:id/show/edit", FMPSecurityLive.Show, :edit
  end
end
