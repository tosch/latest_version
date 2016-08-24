require "active_support/core_ext/object/blank"
require "slackhook"
require "pony"

module LatestVersion
  class GitHubRelease < Sequel::Model(:releases)
    many_to_one :repository, class: :GitHubRepository, class_namespace: :LatestVersion, key: :repository_id

    def self.new_latest_release_for(repository, github_data = nil)
      octokit = repository.user.github_client

      github_data = if github_data
                      Sawyer::Resource.new(octokit.agent, github_data)
                    else
                      fetch_from(Sawyer::Relation.from_link(octokit.agent, :releases, repository.releases_url))
                    end

      if (github_data && repository.latest_release && repository.latest_release.uid == github_data.id) || !github_data
        nil
      else
        create_from(github_data)
      end
    end

    def send_email
      subject = "New release #{name} for #{repository.full_name}"

      message = <<~EOT
        Hello #{user.username},

        I'd like to inform you that there is a new release for #{repository.full_name}:

        # #{name} (tag: #{tag_name})

        #{description}

        #{html_url}

        That's it for now.

        Cheers, your friendly latest version bot.
      EOT

      Pony.mail(to: user.email,
                from: ENV["VERSION_EMAIL_FROM"],
                body: message,
                subject: subject)
    end

    def send_slack
      return unless user.slackhook_url && !user.slackhook_url.empty?

      message = ":star: New release #{name} for #{repository.full_name}: #{html_url} :star:"

      Slackhook.send_hook(webhook_url: user.slackhook_url,
                          username: "latest_version_bot",
                          icon_type: ":new:",
                          text: message)
    end

    private

    def self.fetch_from(relation)
      relation.get(uri: {id: "latest"}).data
    rescue Octokit::NotFound
      nil
    end

    def self.create_from(github_data)
      create({
        uid: github_data.id,
        tag_name: github_data.tag_name,
        name: github_data.name,
        description: github_data.body,
        html_url: github_data.html_url,
        published_at: github_data.published_at
      })
    end

    def user
      repository.user
    end
  end
end
