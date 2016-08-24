require "sinatra"
require "omniauth"
require "omniauth-github"
require "octokit"
require "openssl"

require "pry-byebug" if ENV['RACK_ENV'] == "development"

module LatestVersion

  class App < Sinatra::Base
    enable :sessions

    use OmniAuth::Builder do
      provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: "user,repo"
    end

    helpers do
      def current_user
        return nil unless session["user_id"]

        @current_user ||= User[session["user_id"]]
      end
    end

    get "/" do
      if current_user
        # GitHubRepository.fetch_all_from_github_for(current_user) if current_user.outdated?

        haml :index, locals: {repositories: current_user.repositories}
      else
        redirect to("/auth/github")
      end
    end

    post "/update_user" do
      if current_user
        current_user.update(slackhook_url: params[:slackhook_url]) if params[:slackhook_url]
      end

      redirect to("/")
    end

    post "/refresh" do
      if current_user
        GitHubRepository.fetch_all_from_github_for(current_user)
      end

      redirect to("/")
    end

    get "/auth/github/callback" do
      @current_user = User.find_or_create_from(request.env["omniauth.auth"])
      session["user_id"] = @current_user.id

      redirect to("/")
    end

    get "/logout" do
      session["user_id"] = nil
      @current_user = nil

      redirect to("/")
    end

    post "/register_github_event" do
      if current_user
        repository = LatestVersion::GitHubRepository[params[:repository_id]]

        if repository
          repository.register_github_event(uri("/")) unless repository.registered_github_event?
          repository.unregister_github_event if repository.registered_github_event? && "1" == params[:unregister_github_event]

          repository.update(webhook_send_mail: params[:send_email], webhook_send_slack: params[:send_slack])
        end
      end

      redirect to("/")
    end

    post "/github_event/:user_id/:repo_id" do |user_id, repo_id|
      repository = GitHubRepository[repo_id]

      return halt 404, "Not Found" unless repository

      request.body.rewind
      payload_body = request.body.read
      verify_webhook_signature(payload_body, repository)

      push = JSON.parse(payload_body)

      if "published" == push["action"]
        release = GitHubRelease.new_latest_release_for(repository, push["release"])

        if release
          release.repository = repository
          release.save

          release.send_email if repository.webhook_send_mail
          release.send_slack if repository.webhook_send_slack
        end
      end

      halt 204
    end

    def verify_webhook_signature(payload_body, repository)
      signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), repository.webhook_secret, payload_body)
      return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
    end
  end
end
