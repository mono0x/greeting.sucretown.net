require 'bundler'
Bundler.require :schedule

def execute_command(command)
  result = `#{command} 2>&1`
  return if result.empty?
  STDERR.puts result
  gmail = Gmail.new(ENV['GMAIL_ADDRESS'], ENV['GMAIL_PASSWORD'])
  gmail.deliver do
    to      ENV['GMAIL_ADDRESS']
    subject "Schedule #{command}"
    body    result
  end
end

scheduler = Rufus::Scheduler.start_new

scheduler.cron '0 * * * *' do
  execute_command 'bundle exec rake crawler:update'
end

scheduler.join
