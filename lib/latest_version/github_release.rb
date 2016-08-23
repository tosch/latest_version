module LatestVersion
  class GitHubRelease
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def name
      data.name
    end

    def tag
      data.tag_name
    end

    def html_url
      data.html_url
    end

    def to_h
      {latest_version: name, tag: tag, html_url: html_url}
    end
  end
end
