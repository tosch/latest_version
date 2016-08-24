module LatestVersion
  class GitHubRepository < Sequel::Model(:repositories)
    many_to_one :user, class: :User, class_namespace: :LatestVersion, key: :user_id
    one_to_many :releases, class: :GitHubRelease, class_namespace: :LatestVersion, key: :repository_id

    def self.fetch_all_from_github_for(user)
      Octokit.auto_paginate = true

      DB.transaction do
        user.github_client.repos.map { |repo_data| find_or_create_from_github(repo_data, user) }
      end
    end

    def self.find_or_create_from_github(data, user)
      existing_repository = user.repositories_dataset.where(uid: data.id).first

      if existing_repository
        existing_repository.update_latest_release

        existing_repository
      else
        create({
          uid: data.id,
          full_name: data.full_name,
          url: data.url,
          html_url: data.html_url,
          releases_url: data.releases_url,
          user_id: user.id
        })
      end
    end

    def after_create
      super

      update_latest_release
    end

    def update_latest_release
      release = GitHubRelease.new_latest_release_for(self)

      add_release(release) if release
    end

    def released?
      !releases_dataset.empty?
    end

    def latest_release
      releases_dataset.order(:created_at).last
    end

    def register_github_event(base_path)
      self.webhook_secret = SecureRandom.hex(20)

      data = user.github_client.create_hook(full_name,
                                            "web",
                                            {url: github_event_url(base_path), content_type: "json", secret: webhook_secret},
                                            {events: ["release"], active: true})

      self.webhook_uid = data.id

      save
    end

    def unregister_github_event
      return unless registered_github_event?

      hook = user.github_client.hook(full_name, webhook_uid)
    rescue Octokit::NotFound
    else
      user.github_client.delete(hook.url)
    ensure
      update(webhook_uid: nil, webhook_secret: nil)
    end

    def registered_github_event?
      webhook_uid && webhook_secret
    end

    private

    def github_event_url(base_path)
      base_path + "github_event/#{user.id}/#{id}"
    end
  end
end
