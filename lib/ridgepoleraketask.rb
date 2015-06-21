require 'rake/tasklib'

class RidgepoleRakeTask < Rake::TaskLib
  attr_accessor :database_uri

  def initialize
    yield self if block_given?
    define
  end

  def define
    task :export do
      database_config do |file|
        system "ridgepole -c #{file} --o Schemafile --export"
      end
    end

    task :apply do
      database_config do |file|
        system "ridgepole -c #{file} --o Schemafile --apply"
      end
    end
  end

  private

  def database_config
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
