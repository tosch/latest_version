require "sinatra"
require "omniauth"
require "omniauth-github"
require "octokit"

require "pry-byebug" if ENV['RACK_ENV'] == "development"

module LatestVersion

  class App < Sinatra::Base
    enable :sessions

    get "/" do
      if session['user']
        haml :index, locals: {repositories: GitHubRepository.all_for(session["user"])}
      else
        redirect to("/auth/github")
      end
    end

    use OmniAuth::Builder do
      provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: "user,repo"
    end

    get "/auth/github/callback" do
      session['user'] = User.new(request.env["omniauth.auth"])

      redirect to("/")
    end

    get "/logout" do
      session["user"] = nil

      redirect to("/")
    end
  end
end
