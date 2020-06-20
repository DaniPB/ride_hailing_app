threads_count = 5 
threads threads_count, threads_count

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
port        ENV.fetch("PORT") { 8080 }

puts "*" * 100
# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch("RACK_ENV") { "development" }
