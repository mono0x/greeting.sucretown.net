require 'bundler'
Bundler.require :schedule

require 'logger'

require_relative 'lib/slackclient'

def execute_command(command)
  logger = Logger.new(STDERR)
  logger.info command

  result = `#{command} 2>&1`
  logger.error "status = #$?" unless $? == 0
  return if result.empty?

  error = ($? != 0)
  if error
    logger.error result
  else
    logger.info result
  end

  slack = SlackClient.new
  slack.send("`$ #{command}`\n```#{result}```", {
    username: 'puroland-greeting',
    icon_emoji: error ? ':sob:' : ':innocent:',
  })
end

scheduler = Rufus::Scheduler.new
mutex = Mutex.new

scheduler.cron '*/15 8-21 * * *', mutex: mutex do
  execute_command 'bundle exec rake crawler:update'
end

scheduler.cron '1-14,16-29,31-44,46-59 8-10 * * *', mutex: mutex do
  execute_command 'bundle exec rake crawler:register'
end

scheduler.cron '30 3 * * *' do
  execute_command 'bundle exec rake backup:run'
end

scheduler.cron '0 0 * * *' do
  execute_command 'bundle exec rake varnish:purge'
end

scheduler.join
