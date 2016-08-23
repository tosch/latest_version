require "sinatra"
require "omniauth"
require "omniauth-github"
require "octokit"

require "pry-byebug" if ENV['RACK_ENV'] == "development"

module LatestVersion
  class User
    attr_reader :auth

    def initialize(auth)
      @auth = auth
    end

    def token
      auth.dig("credentials", "token")
    end
  end

  class App < Sinatra::Base
    enable :sessions

    get "/" do
      if session['user']
        Octokit.auto_paginate = true

        github = Octokit::Client.new(access_token: session["user"].token)
        data = github.repos.map do |repo|
                 begin
                   release = repo.rels[:releases].get(uri: {id: "latest"}).data
                   {repository: repo.full_name, latest_version: release.name, tag: release.tag_name, html_url: release.html_url}
                 rescue Octokit::NotFound
                   next
                 end
               end

        data.reject!(&:nil?)

        haml :index, locals: {data: data}
      else
        redirect "/auth/github"
      end
    end

    use OmniAuth::Builder do
      provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: "user,repo"
    end

    get "/auth/github/callback" do
      session['user'] = User.new(request.env["omniauth.auth"])

      redirect "/"
    end

    get "/logout" do
      session["user"] = nil

      redirect "/"
    end
  end
end
