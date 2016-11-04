defmodule Vutuv.Router do
  use Vutuv.Web, :router
  alias Vutuv.Plug, as: Plug

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.EmailPreviewPlug
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    #plug Vutuv.Plug.ManageCookies
    plug :put_secure_browser_headers
    plug Plug.ConfigureSession, repo: Vutuv.Repo
    plug Plug.Locale
  end

  pipeline :user_pipe do
    plug Plug.UserResolveSlug
  end

  pipeline :api do
    plug :accepts, ["json-api"]
    plug Plug.PutAPIHeaders
  end

  scope "/", Vutuv do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/new_registration", PageController, :redirect_index
    post "/new_registration", PageController, :new_registration

    # TODO: delete the following route entries
    resources "/memberships", MembershipController
    resources "/connections", ConnectionController, only: [:new, :create, :show, :delete, :index] do
      resources "/memberships", MembershipController, only: [:new, :create, :show, :delete, :index]
    end

    resources "/search_queries", SearchQueryController, only: [:create, :index, :new, :show]

    resources "/skills", SkillController, only: [:show, :index], param: "slug"

    resources "/users", UserController, param: "slug" do
      pipe_through :user_pipe
      resources "/emails", EmailController
      resources "/slugs", SlugController, only: [:index, :new, :create, :show, :update]
      resources "/groups", GroupController
      resources "/followers", FollowerController, only: [:index]
      resources "/followees", FolloweeController, only: [:index]
      resources "/skills", UserSkillController, only: [:new, :create, :show, :delete, :index]
      resources "/endorsements", EndorsementController, only: [:create, :delete]
      resources "/phone_numbers", PhoneNumberController
      resources "/dates", DateController
      resources "/links", UrlController
      resources "/social_media_accounts", SocialMediaAccountController
      resources "/work_experiences", WorkExperienceController
      resources "/addresses", AddressController
      resources "/oauth_providers", OAuthProviderController
      resources "/search_terms", SearchTermController, only: [:show,:index]
    end


    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/magic/login/:magiclink", SessionController, :show
    get "/magic/delete/:magiclink", UserController, :magic_delete
    get "/magic/email/:magiclink", EmailController, :magic_create
    get "/follow_back/:id", UserController, :follow_back
  end

  scope "/admin", as: :admin do
    pipe_through :browser
    resources "/", Vutuv.Admin.AdminController, only: [:index]
    post "/slugs", Vutuv.Admin.SlugController, :update
    post "/users", Vutuv.Admin.UserController, :update
  end

  scope "/api/1.0/", as: :api do
    pipe_through :api
    resources "/skills", Vutuv.Api.SkillController, only: [:index, :show]
    resources "/users", Vutuv.Api.UserController, param: "slug" do
      pipe_through :user_pipe
      resources "/emails", Vutuv.Api.EmailController, only: [:index, :show]
      resources "/slugs", Vutuv.Api.SlugController, only: [:index, :show]

      resources "/groups", Vutuv.Api.GroupController, only: [:index, :show]
      resources "/followers", Vutuv.Api.FollowerController, only: [:index]
      resources "/followees", Vutuv.Api.FolloweeController, only: [:index]

      resources "/skills", Vutuv.Api.UserSkillController, only: [:index, :show]
      #resources "/endorsements", Vutuv.Api.EndorsementController, only: [:create, :delete]
      resources "/phone_numbers", Vutuv.Api.PhoneNumberController, only: [:index, :show]
      resources "/links", Vutuv.Api.UrlController, only: [:index, :show]
      resources "/social_media_accounts", Vutuv.Api.SocialMediaAccountController, only: [:index, :show]
      resources "/work_experiences", Vutuv.Api.WorkExperienceController, only: [:index, :show]
      resources "/addresses", Vutuv.Api.AddressController, only: [:index, :show]
      resources "/search_terms", Vutuv.Api.SearchTermController, only: [:index, :show]

      get "/vcard", Vutuv.Api.VCardController, :get
    end
  end
end
