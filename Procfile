worker: bundle exec sidekiq -C config/sidekiq.yml

web: bundle exec rails server thin -p $PORT
log: tail -f -n 40 log/development.log