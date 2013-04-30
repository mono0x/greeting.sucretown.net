# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'pow' do
  watch('.powrc')
  watch('.powenv')
  watch('.rbenv-version')
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('config.ru')
  watch(%r{^lib/.*\.rb$})
end

guard 'bundler' do
  watch('Gemfile')
  # Uncomment next line if Gemfile contain `gemspec' command
  # watch(/^.+\.gemspec/)
end
