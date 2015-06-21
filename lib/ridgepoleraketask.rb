require 'rake/tasklib'

class RidgepoleRakeTask < Rake::TaskLib
  attr_accessor :ridgepole_command
  attr_accessor :database_uri, :schemafile_path
  attr_accessor :export_name, :apply_name

  def initialize
    @ridgepole_command = 'ridgepole'
    @database_uri = ENV['DATABASE_URL']
    @schemafile_path = 'Schemafile'
    @export_name = :export
    @apply_name = :apply
    yield self if block_given?
    define
  end

  def define
    task @export_name do
      database_config do |file|
        system "#@ridgepole_command -c #{file} --o #@schemafile_path --export"
      end
    end

    task @apply_name do
      database_config do |file|
        system "#@ridgepole_command -c #{file} --o #@schemafile_path --apply"
      end
    end
  end

  private

  def database_config
    raise 'block is required' unless block_given?
    Tempfile.open([ 'database', '.yml' ]) do |f|
      uri = URI.parse(@database_uri.to_s)
      YAML.dump({
        'adapter' => uri.scheme || 'postgresql',
        'encoding' => 'utf8',
        'host' => uri.host,
        'port' => uri.port || 5432,
        'database' => uri.path.delete('/'),
        'username' => uri.user,
        'password' => uri.password,
      }, f)
      f.flush

      yield f.path
    end
  end
end
