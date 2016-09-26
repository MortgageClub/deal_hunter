require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
require 'mina/rvm'    # for rvm support. (http://rvm.io)
require 'mina/puma'
require 'mina/whenever'

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :domain, 'dealhunter.mortgageclub.co'
set :deploy_to, '/var/www/dh'
set :repository, 'git@github.com:MortgageClub/deal_hunter.git'
set :branch, 'master'
# set :branch, 'feature/deploy_to_production'

# For system-wide RVM install.
#   set :rvm_path, '/usr/local/rvm/bin/rvm'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['config/database.yml', 'config/secrets.yml', 'log', 'tmp/pids', 'tmp/sockets']

# Optional settings:
set :user, 'deploy'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.
set :forward_agent, true     # SSH forward_agent.

set_default :delayed_job_pid_dir, lambda { "#{deploy_to}/#{shared_path}/tmp/pids" }

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  invoke :'rvm:use[ruby-2.2.2@default]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  # Puma needs a place to store its pid file and socket file.
  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/tmp/sockets")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/tmp/sockets")
  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/tmp/pids")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/tmp/pids")

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config"]

  queue! %[touch "#{deploy_to}/#{shared_path}/config/database.yml"]
  queue! %[touch "#{deploy_to}/#{shared_path}/config/secrets.yml"]
  queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/database.yml' and 'secrets.yml'."]

  queue %[
    repo_host=`echo $repo | sed -e 's/.*@//g' -e 's/:.*//g'` &&
    repo_port=`echo $repo | grep -o ':[0-9]*' | sed -e 's/://g'` &&
    if [ -z "${repo_port}" ]; then repo_port=22; fi &&
    ssh-keyscan -p $repo_port -H $repo_host >> ~/.ssh/known_hosts
  ]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  to :before_hook do
    # Put things to run locally before ssh
  end

  invoke :env

  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :db_seed
    invoke :'rails:assets_precompile'

    to :launch do
      queue "mkdir -p #{deploy_to}/#{current_path}/tmp/"
      queue "touch #{deploy_to}/#{current_path}/tmp/restart.txt"

      # Stop delayed_job
      queue "ps aux | grep delayed_job | grep -v grep| awk {'print $2'} | xargs -r kill -s QUIT"

      # Start delayed_job
      queue "cd #{deploy_to}/#{current_path} && RAILS_ENV=production bin/delayed_job start --pid-dir=#{delayed_job_pid_dir}"

      invoke :'whenever:clear'
      invoke :'whenever:update'
      invoke :'deploy:cleanup'

      invoke :'puma:stop'
      invoke :'puma:start'
    end
  end
end

task :env do
  queue %{
    echo "-----> Loading environment"
    #{echo_cmd %[source ~/.bash_profile]}
  }
end

task :db_seed do
  queue "cd #{deploy_to}/#{current_path}/"
  queue "bundle exec rake db:seed RAILS_ENV=production"
  queue  %[echo "-----> Rake Seeding Completed."]
end
