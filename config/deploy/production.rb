role :web, "WEB SERVER IP"
role :app, "APP SERVER IP"
role :db, "DB SERVER IP", :primary => true

# Prompt to make really sure we want to deploy into prouction
puts "\n\e[0;31m   ######################################################################"
puts "   #\n   #       Are you REALLY sure you want to deploy to production?"
puts "   #\n   #               Enter y/N + enter to continue\n   #"
puts "   ######################################################################\e[0m\n"
proceed = STDIN.gets[0..0] rescue nil
exit unless proceed == 'y' || proceed == 'Y' 

random = (0...10).map { ('a'..'z').to_a[rand(26)] }.join
puts "\n\e[0;31m   ######################################################################"
puts "   #\n   #       Prove it. To continue type: #{random}\n   #"
puts "   ######################################################################\e[0m\n"
proceed = STDIN.gets rescue nil
exit unless proceed.chomp == random.chomp 

set :branch, "master"  
set :rails_env, "production" 
