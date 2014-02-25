root = "/home/deployer/apps/YOURAPPNAME/current"
working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.error.log"
stdout_path "#{root}/log/unicorn.log"

listen 8080
worker_processes 2
timeout 30
