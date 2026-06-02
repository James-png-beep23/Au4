defmodule Au4Web.Router do
  use Au4Web, :router

  import Au4Web.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Au4Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :owner_only do
    plug :require_authenticated_user #plug to ensure the user is authenticated
    plug :require_owner_role # plug to ensure the user has the "Owner" role
  end

  scope "/", Au4Web do
    pipe_through :browser

    get "/", PageController, :home


  end

  # Other scopes may use custom stacks.
  # scope "/api", Au4Web do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:au4, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: Au4Web.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", Au4Web do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{Au4Web.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", Au4Web do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{Au4Web.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      live "/apartments", ApartmentLive.Index, :index
      live "/apartments/new", ApartmentLive.Index, :new
      live "/apartments/:id/edit", ApartmentLive.Index, :edit

      live "/apartments/:id", ApartmentLive.Show, :show
      live "/apartments/:id/show/edit", ApartmentLive.Show, :edit

      live "/roles", RoleLive.Index, :index
      live "/roles/new", RoleLive.Index, :new
      live "/roles/:id/edit", RoleLive.Index, :edit

      live "/roles/:id", RoleLive.Show, :show
      live "/roles/:id/show/edit", RoleLive.Show, :edit

      live "/userapartments", UserApartmentLive.Index, :index
      live "/userapartments/new", UserApartmentLive.Index, :new
      live "/userapartments/:id/edit", UserApartmentLive.Index, :edit
      live "/apartments/:apartment_id/assign_member", UserApartmentLive.Assign, :index

      live "/view", ViewApartmentLive.Index, :index
      live "/view/:id", ViewApartmentLive.Show, :show
      live "/requests", RequestLive.Index, :index

       live "/admin/users/roles", AccessLive.Index, :index



      scope "/admin" do
      pipe_through [:owner_only]
      get "/dashboard", AdminController, :index

      end

      scope "/portal" do
      pipe_through [:owner_only]
      get "/dashboard", AdminController, :index
     end
    end
  end

  live_session :owner_only,
    on_mount: [{Au4Web.UserAuth, :ensure_owner}],
    layout: {Au4Web.Layouts, :admin} do # This applies the layout to all LiveViews in this session
      live "/admin/advanced-stats", AdminLive.Stats, :index
      live "/portal/advanced-stars", AdminLive.Stats, :portal_dashboard
end


  scope "/", Au4Web do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{Au4Web.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
