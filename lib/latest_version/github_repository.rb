module LatestVersion
  class GitHubRepository
    def self.all_for(user)
      Octokit.auto_paginate = true

      github_client_for(user).repos.map { |repo_data| new(repo_data) }
    end

    attr_reader :data

    def initialize(data)
      @data = data
    end

    def full_name
      data.full_name
    end

    def released?
      !!latest_release_data
    end

    def latest_release
      @latest_release ||= GitHubRelease.new(latest_release_data) if released?
    end

    def to_h
      {full_name: full_name, latest_release: latest_release.try(:to_h)}
    end

    private

    def self.github_client_for(user)
      Octokit::Client.new(access_token: user.token)
    end

    def latest_release_data
      return @latest_release_data unless @latest_release_data.nil?

      @latest_release_data = data.rels[:releases].get(uri: {id: "latest"}).data
    rescue Octokit::NotFound
      @latest_release_data = false
    end
  end
end
