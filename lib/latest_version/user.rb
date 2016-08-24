module LatestVersion
  class User < Sequel::Model(:users)
    one_to_many :repositories, class: :GitHubRepository, class_namespace: :LatestVersion, key: :user_id, eager: [:releases]

    def self.find_or_create_from(auth)
      where(uid: auth["uid"]).first || begin
                                          user = new(username: auth["info"]["nickname"],
                                                     email: auth["info"]["email"],
                                                     uid: auth["uid"],
                                                     token: auth["credentials"]["token"])
                                          user.save

                                          user
                                        end
    end

    def last_update
      last_update = repositories_dataset.max(:updated_at)

      Sequel.string_to_datetime(last_update) if last_update
    end

    def outdated?
      !last_update || last_update < (Time.now - 30 * 60)
    end

    def github_client
      @github_client ||= Octokit::Client.new(access_token: token)
    end
  end
end
