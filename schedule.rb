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

scheduler = Rufus::Scheduler.start_new

scheduler.cron '*/15 8-21 * * *' do
  execute_command 'bundle exec rake crawler:update'
end

scheduler.cron '5,10,20,25,35,40,50,55 8-10 * * *' do
  execute_command 'bundle exec rake crawler:register'
end

scheduler.cron '30 3 * * *' do
  execute_command 'bundle exec rake backup:run'
end

scheduler.cron '0 0 * * *' do
  execute_command 'bundle exec rake varnish:purge'
end

scheduler.join
