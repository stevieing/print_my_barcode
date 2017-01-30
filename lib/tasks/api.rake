# if Rails.env == "development"
#   require 'raml'

#   namespace :docs do
#     desc "generate the api docs"
#     task :api do |t|
#       puts "generating api docs..." 
#       Raml::Parser.parse(File.join(Rails.root,"config","api.raml"), File.join(Rails.root,"app","views","v1","docs","index.html.erb"))
#       puts "done"
#     end
#   end
# end