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
end
