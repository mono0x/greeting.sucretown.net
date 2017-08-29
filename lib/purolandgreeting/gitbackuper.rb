require 'fileutils'
require 'octokit'

module PurolandGreeting
  class GitBackuper
    def run(today = nil, now = nil, registered = nil, diff = nil)
      return if !diff || diff.empty?

      client = Octokit::Client.new(access_token: ENV['GITHUB_API_TOKEN'])

      ltsv = Database.export_by_date(today)

      file = "#{today.strftime('%F')}.ltsv"
      dir = today.strftime('%Y/%m')
      path = "#{dir}/#{file}"

      repository = ENV['GITHUB_TARGET_REPOSITORY']

      if registered
        client.create_contents repository, path, "Add #{file}", ltsv
      else
        content = client.contents(repository, path: path)
        client.update_contents repository, path, "Update #{file}", content[:sha], ltsv
      end
    end
  end
end
