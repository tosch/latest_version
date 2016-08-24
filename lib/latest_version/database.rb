require "sequel"
require "uri"

module LatestVersion
  module Database
    def self.uri
      ENV["DATABASE_URI"]
    end
  end
end

Sequel::Model.plugin :timestamps, update_on_create: true

DB = Sequel.connect(LatestVersion::Database.uri)
