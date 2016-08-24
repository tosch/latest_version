lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

ENV["DATABASE_URI"] = "sqlite://db.sqlite3"

require "latest_version"

run LatestVersion::App
