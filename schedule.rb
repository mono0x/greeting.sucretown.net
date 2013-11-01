require 'bundler'
Bundler.require :schedule

require 'logger'

def execute_command(command)
  logger = Logger.new('shared/schedule.log')
  logger.info command

  result = `#{command} 2>&1`
  logger.error "status = #$?" unless $? == 0
  return if result.empty?

  if $? == 0
    logger.info result
  else
    logger.error result
  end

  STDERR.puts result
  gmail = Gmail.new(ENV['GMAIL_ADDRESS'], ENV['GMAIL_PASSWORD'])
  gmail.deliver do
    to      ENV['GMAIL_ADDRESS']
    subject "Schedule #{command}"
    body    result
  end
end

scheduler = Rufus::Scheduler.start_new

scheduler.cron '0 8-21 * * *' do
  execute_command 'bundle exec rake crawler:update'
end

scheduler.cron '5-55/5 8-10 * * 1-5' do
  execute_command 'bundle exec rake crawler:register'
end

scheduler.cron '15-45/15 8-10 * * 0,6' do
  execute_command 'bundle exec rake crawler:register'
end

scheduler.cron '15 4 * * *' do
  execute_command 'bundle exec rake db:backup'
end

scheduler.join
