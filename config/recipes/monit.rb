namespace :monit do
  desc "Install Monit"
  task :install do
    run "#{sudo} apt-get -y install monit"
  end
  after "deploy:install", "monit:install"

  desc "Setup all Monit configuration"
  task :setup do
    nginx
    postgresql
    unicorn
  end
  after "deploy:setup", "monit:setup"
  after "deploy", "monit:nginx", "monit:postgresql", "monit:unicorn"
  
  task(:nginx, roles: :app) do 
    monit_config "unicorn"
  end

  task(:postgresql, roles: :db) do 
    monit_config "postgresql"
  end

  task(:unicorn, roles: :web) do 
    monit_config "nginx"
  end

  %w[start stop restart syntax reload].each do |command|
    desc "Run Monit #{command} script"
    task(command, roles: :app) do
      run "#{sudo} service monit #{command}"
    end
  end
end

def monit_config(name, destination = nil)
  destination ||= "/etc/monit/conf.d/#{name}.conf"
  template "monit/#{name}.erb", "/tmp/monit_#{name}"
  run "#{sudo} mv /tmp/monit_#{name} #{destination}"
  run "#{sudo} chown root #{destination}"
  run "#{sudo} chmod 600 #{destination}"
end
