require 'fileutils'

module PurolandGreeting
  class GitBackuper
    def run(today = nil, now = nil, registered = nil, diff = nil)
      return if !diff || diff.empty?

      ltsv = Database.export_by_date(today)

      Dir.chdir('shared/puroland-greeting-schedule') do
        file = "#{today.strftime('%F')}.ltsv"
        dir = today.strftime('%Y/%m')
        FileUtils.mkdir_p dir
        path = "#{dir}/#{file}"
        open(path, 'w') do |f|
          f << ltsv
        end
        message = "#{registered ? 'Add' : 'Update'} #{file}"
        system "git add '#{path}' && git commit -m '#{message}'"
        if private_key = ENV['SSH_PRIVATE_KEY_PATH']
          system %{ssh-agent sh -c "ssh-add #{private_key} && git push origin master"}
        end
      end
    rescue
      STDERR.puts $!
    end
  end
end
