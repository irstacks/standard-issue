# git-rails-database-branch-hook

> https://github.com/irstacks/git-rails-database-branch-hook

Save and restore the state of your Rails development and test databases as you work on different branches.

This allows you to make some changes to the structure of your database on a feature branch, then be able to quickly switch back to your master branch to make a hotfix or start a new feature branch with your original database structure and content.

# Installation

Download the `post-checkout` file into the `.git/hooks` directory of your project. Be sure to keep the `post-checkout` name to match Git's expectations.

Alternatively, you can clone this repository to your computer then symlink the `post-checkout` file into the `.git/hooks` directory of each of your projects. This allows you to manage the file in one place and be able to easily pull down updates.

# Support

Only PostgreSQL and MySQL databases are currently supported.

# Non-Rails Usage

While this hook is geared towards Rails and depends on Ruby, it is very easy to use it in non-Ruby/Rails projects, so long as you have Ruby installed on your system.

This script will look for a `config/database.yml` file in your project's root directory, and expects it to look like this:

```yaml
development:
  adapter: <adapter>
  username: <database username>
  password: <database password>
  database: <database name>
```

We currently support two adapters: `mysql2` and `postgresql`. We don't actually rely on these gems, but instead use them to determine which database's command line tools we should use (mysqldump/mysql or pg_dump/psql). Use `mysql2` if you are using a MySQL database, or `postgresql` if you are using a PostgreSQL database.

### Gotcha: And make sure you make the hook executable.

```bash
$ chmod +x .git/hooks/post-checkout
```

```
#!/usr/bin/env ruby

require 'yaml'

class UnsupportedDatabaseAdapter < RuntimeError

  attr_reader :adapter

  def initialize(adapter)
    @adapter = adapter
  end

  def message
    "Adapter `#{adapter}` is not supported."
  end

end

# If this was a branch checkout
if ARGV[2] == '1'
  def dump(env, branch_name)
    print "Saving state of #{env} database on '#{branch_name}' branch..."

    if system(dump_cmd(env, branch_name))
      print "done!\n"
      true
    else
      print "failed!\n"
      false
    end
  rescue UnsupportedDatabaseAdapter => e
    puts "\nERROR: #{e.message}"
  end

  def dump_file(database_name, branch_name)
    # Replace any special characters that may cause file system issues
    branch_name = branch_name.gsub(/[^0-9a-z.\-_]/i, '_')

    "#{@dump_folder}/#{database_name}-#{branch_name}"
  end

  def dump_cmd(env, branch_name)
    adapter = @rails_db_config[env]['adapter']

    case adapter
    when 'postgresql'
      pg_dump_cmd(env, branch_name)
    when 'mysql2'
      mysql_dump_cmd(env, branch_name)
    else
      raise UnsupportedDatabaseAdapter.new(adapter)
    end
  end

  def pg_dump_cmd(env, branch_name)
    database_name = @rails_db_config[env]['database']

    %[pg_dump --file="#{dump_file(database_name, branch_name)}" #{database_name}]
  end

  def mysql_dump_cmd(env, branch_name)
    database_name = @rails_db_config[env]['database']
    username = @rails_db_config[env]['username']
    password = @rails_db_config[env]['password']

    %[mysqldump --add-drop-database --user=#{username} --password="#{password}" --databases #{database_name} > "#{dump_file(database_name, branch_name)}"]
  end

  def restore(env, path)
    system(restore_cmd(env, path))
  end

  def restore_cmd(env, path)
    adapter = @rails_db_config[env]['adapter']

    case adapter
    when 'postgresql'
      pg_restore_cmd(env, path)
    when 'mysql2'
      mysql_restore_cmd(env, path)
    else
      raise UnsupportedDatabaseAdapter.new(adapter)
    end
  end

  def pg_restore_cmd(env, path)
    database_name = @rails_db_config[env]['database']

    drop_existing_pg_connections_to_database(database_name)

    drop_pg_database(database_name)
    create_pg_database(database_name)

    %[psql --file="#{path}" #{database_name} > /dev/null]
  end

  def drop_existing_pg_connections_to_database(database_name)
    system(%[psql --command="SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '#{database_name}' AND pid <> pg_backend_pid();" postgres > /dev/null])
  end

  def drop_pg_database(database_name)
    system(%[dropdb #{database_name}])
  end

  def create_pg_database(database_name)
    system(%[createdb #{database_name}])
  end

  def mysql_restore_cmd(env, path)
    database_name = @rails_db_config[env]['database']
    username = @rails_db_config[env]['username']
    password = @rails_db_config[env]['password']

    %[mysql -u #{username} --password="#{password}" #{database_name} < "#{path}"]
  end

  def branches_from_refhead(ref)
    `git show-ref --heads | grep #{ref} | awk '{print $2}'`.split("\n").map{ |b| b.sub(/^refs\/heads\//, '') }
  end

  # Get the current (destination) branch
  @destination_branch = `git rev-parse --abbrev-ref HEAD`.strip

  # Since we're just given a commit ID referencing the branch head we're coming from,
  # it could be at the head of multiple branches. We can assume the source isn't the same as the
  # destination branch, so we can remove that immediately.
  @source_branches = branches_from_refhead(ARGV[0]).reject{ |b| b == @destination_branch }

  @project_root = %x[git rev-parse --show-toplevel].strip
  @dump_folder = "#{@project_root}/.db_branch_dumps"

  # Load Rails DB config and grab database name
  @rails_db_config = YAML.load_file("#{@project_root}/config/database.yml")
  dev_database_name = @rails_db_config['development']['database']

  # Ensure dump directory exists
  unless Dir.exists?(@dump_folder)
    Dir.mkdir @dump_folder
  end

  # Don't do anything if the source and destination branches are the same or nonexistent
  unless @source_branches.include?(@destination_branch) || @source_branches.empty? || (@source_branches | [@destination_branch]).any?{ |b| b == '' }
    # Dump database for source branches
    if @source_branches.all? { |branch| dump('development', branch) }
      # Restore dump from this branch, if it exists
      dump_path = dump_file(dev_database_name, @destination_branch)

      if File.exists?(dump_path)
        print "Restoring #{dev_database_name} to its previous state on this branch..."

        if restore('development', dump_path)
          print "done!\n"

          # If we have a structure.sql file, restore that to the test database,
          # otherwise fall back to rake
          structure_sql = File.join(@project_root, 'db', 'structure.sql')

          if File.exists?(structure_sql)
            print "Restoring test database from structure.sql..."

            print restore('test', structure_sql) ? "done!\n" : "failed!\n"
          elsif File.exists?("#{@project_root}/Rakefile")
            print "Preparing test database..."

            rake_cmd = "rake db:test:prepare"

            if File.exists?("#{@project_root}/bin/rake")
              rake_cmd = "./bin/#{rake_cmd}"
            elsif File.exists?("#{@project_root}/Gemfile")
              rake_cmd = "bundle exec #{rake_cmd}"
            end

            system rake_cmd

            print "done!\n"
          else
            print "No structure.sql or Rakefile detected, skipping test database restoration\n"
          end
        else
          print "failed!\n"
        end
      else
        print "No DB dump for #{dev_database_name} on the '#{@destination_branch}' branch was found!\n"
        print "The state of your database has been saved for when you return to the '#{@source_branches.join('\' or \'')}' branch, but its current state has been left unchanged.  You are now free to make changes to it that are specific to this branch, and they will be saved when you checkout a different branch, then restored when you checkout this one again.\n"
      end
    else
      print "Failed to dump database. Halting.\n"
    end
  end
end
```