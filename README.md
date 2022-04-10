# Technical details
rails 5.2.1
ruby 2.5.1

# Installation
- git clone
- create `config/database.yml` from example
- create `.env` from example, don't forget to run `source env` after that
- `bundle install`
- rails db:create && rails db:migrate (ensure that postgres is installed)
- rails db:seed

## *Using docker-compose*
1. [Install Docker](https://docs.docker.com/get-docker/).
2. Build `parkings-app:latest` image run: `docker-compose build --no-cache --force-rm app`.
2. Run `copy .env.example .env` & `docker-compose up` it will pull Postgres & Redis image & up all services described at `docker-compose.yml`.
3. Browse:
    - dashboard API backend at [localhost:3000](http://localhost:3000).
    - Mailcatcher at [localhost:1080](http://localhost:1080)

* ### Rebuild `parkings-app:latest` image:
    If you add new gem to Gemfile, rebuild base image with: `docker-compose build --no-cache --force-rm app`.
* ### Tesing with docker-compose
    Run all specs: `docker-compose run test rspec`  
or pass specific file: `docker-compose run test rspec spec/path-to/file_spec.rb`  
    You able to up test container: `docker-compose run test bash` and then run inside rspec `rspec` or `rspec spec/path-to/file_spec.rb` and repeat it for check.
   
* ### Compose tips
    If you already run `docker-compose up` you able to ssh into the container run `docker-compose exec app bash`.  
    Exec inside runned container any command: `docker-compose exec app bundle exec rails console`.  
    Run new container & exec command: `docker-compose run app bundle exec rails g migration ...`   
    Browse currently running containers: `docker-compose ps`.   
    If you edit you Gemfile and need bundle install please run `docker-compose run app bundle install` and `rebuild` image again to have this gem at the next application run.

# Tabulation
1 tab = 2 spaces


