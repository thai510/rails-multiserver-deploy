role :web, "STAGING SERVER: WEB IP"
role :app, "STAGING SERVER: APP IP"
role :db, "STAGING SERVER: DB IP", :primary => true

puts "\nList of all branches (* indicates current):"
puts "#{`git branch`}\n"
puts "What branch do you want to deploy?"
branch_to_set = STDIN.gets rescue nil
set :branch, branch_to_set.chomp  
set :rails_env, "staging" 
