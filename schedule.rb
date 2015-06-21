require 'bundler'
Bundler.require :schedule

require 'logger'

def execute_command(command)
  logger = Logger.new(STDERR)
  logger.info command

  result = `#{command} 2>&1`
  logger.error "status = #$?" unless $? == 0
  return if result.empty?

  if $? == 0
    logger.info result
  else
    logger.error result
  end

  gmail = Gmail.connect!(ENV['GMAIL_ADDRESS'], ENV['GMAIL_PASSWORD'])
  gmail.deliver! do
    to      ENV['GMAIL_ADDRESS']
    subject "Schedule #{command}"
    body    result
  end
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
