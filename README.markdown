# USASearch Info

## Code Status

 [![Build Status](https://circleci.com/gh/GSA/search-gov.svg?style=svg)](https://circleci.com/gh/GSA/search-gov)
 [![Maintainability](https://api.codeclimate.com/v1/badges/fd0577360749c9b3d166/maintainability)](https://codeclimate.com/github/GSA/search-gov/maintainability)

## Dependencies

### Docker

The search-gov app and its required services (Redis, MySQL, etc.) can all be installed and run using [Docker](https://www.docker.com/get-started). If you prefer to install the services and packages without Docker, see the [wiki](https://github.com/GSA/search-gov/wiki/Local-Installation-and-Management-of-dependencies). We recommend setting the max memory alloted to Docker to 4GB (in Docker Desktop, Preferences > Resources > Advanced). All of the `docker-compose exec ...` commands below require you to have a running app container via `docker-compose up`. See [the wiki](https://github.com/GSA/search-gov/wiki/Docker-Command-Reference) for more documentation on Docker commands.
    
### Services
The required services listed below can be configured and run using Docker. You can run them all, including the search-gov app, with `docker-compose up`. Alternatively, you can run them individually, i.e. `docker-compose up elasticsearch`.  

* [Elasticsearch](https://www.elastic.co/elasticsearch/) 6.8 - for full-text search and query analytics

We have configured Elasticsearch 6.8 to run on port 9268, and Elasticsearch 7.7 to run on 9277. (Currently, only 6.8 is used in production, but some tests run against both versions.) To check Elasticsearch settings and directory locations:

    $ curl "localhost:9268/_nodes/settings?pretty=true"
    $ curl "localhost:9277/_nodes/settings?pretty=true"
    
* [Kibana](https://www.elastic.co/kibana) - Kibana is not required, but can be very useful for debugging Elasticsearch. Confirm Kibana is available for the Elasticsearch 6.8 cluster by visiting <http://localhost:5668>.

* [MySQL](https://dev.mysql.com/doc/refman/5.6/en/) 5.6 - database, accessible from user 'root' with no password
* [Redis](https://redis.io/) 5.0 - We're using the Redis key-value store for caching, queue workflow via Resque, and some analytics.
* [Tika](https://tika.apache.org/) - for extracting plain text from PDFs, etc. The [Tika REST server](https://cwiki.apache.org/confluence/display/TIKA/TikaServer) runs on <http://localhost:9998/>.

### Packages
The packages below are included in the [custom Docker image](/Dockerfile) used for building the search-gov `app` container.

* C++ compiler - required by the [cld3](https://github.com/akihikodaki/cld3-ruby) gem, which we use for language detection
* Google's [protocol buffers](https://developers.google.com/protocol-buffers/) - also required by the cld gem
* [Java Runtime Environment](https://www.java.com/en/download/)
* [PhantomJS](http://phantomjs.org/download.html) - required to run JavaScript in Cucumber features

## Gems

The Docker app container automatically installs gems when the container is built. If you make any changes to the gems, you should rebuild the app image:

    $ docker-compose build app

## Service credentials; how we protect secrets

The app does its best to avoid interacting with most remote services during the test phase through heavy use of the [VCR](https://github.com/vcr/vcr) gem.

You should be able to simply run this command to get a valid `secrets.yml` file that will work for running existing specs:

    $ cp config/secrets.yml.dev config/secrets.yml

If you find that you need to run specs that interact with a remote service, you'll need to put valid credentials into your `secrets.yml` file.

Anything listed in the `secret_keys` entry of that file will automatically be masked by VCR in newly-recorded cassettes.

## Database


Create and set up your development and test databases:

    $ docker-compose exec app bin/rails db:setup
    $ docker-compose exec app app bin/rails db:test:prepare

## Asset pipeline

A few tips when working with asset pipeline:

* Ensure that your asset directory is in the asset paths by running the following in the console:

    > Rails.application.assets.paths

* Find out which file is served for a given asset path by running the following in the console:

    > Rails.application.assets['relative_path/to_asset.ext']
     
### Indexes

You can create the USASearch-related indexes like this:

    $ docker-compose exec app rake usasearch:elasticsearch:create_indexes

You can index all the records from ActiveRecord-backed indexes like this:

    $ docker-compose exec app rake usasearch:elasticsearch:index_all[FeaturedCollection+BoostedContent]

If you want it to run in parallel using Resque workers, call it like this:

    $ docker-compose exec app rake usasearch:elasticsearch:resque_index_all[FeaturedCollection+BoostedContent]

Note that indexing everything uses whatever index/mapping/setting is in place. If you need to change the Elasticsearch schema first, do this:

    $ docker-compose exec app rake usasearch:elasticsearch:recreate_index[FeaturedCollection]

If you are changing a schema and want to migrate the index without having it be unavailable, do this:

    $ docker-compose exec app rake usasearch:elasticsearch:migrate[FeaturedCollection]

Same thing, but using Resque to index in parallel:

    $ docker-compose exec app rake usasearch:elasticsearch:resque_migrate[FeaturedCollection]

# Tests

Make sure the unit tests, functional and integration tests run:
    
    # Run the RSpec tests
    $ docker-compose exec app bundle exec rspec spec/
    
    # Run the Cucumber integration tests
    $ docker-compose exec app bundle exec cucumber features/

## Circle CI

We use [CircleCI](https://circleci.com/gh/GSA/usasearch) for continuous integration. Build artifacts, such as logs, are available in the 'Artifacts' tab of each CircleCI build.

# Code Coverage

We track test coverage of the codebase over time, to help identify areas where we could write better tests and to see when poorly tested code got introduced. After running the tests (both RSpec & Cucumber), open `coverage/index.html` in your favorite browser to view the report.

You can click around on the files that have < 100% coverage to see what lines weren't exercised.

Make sure you commit any changes to the coverage directory back to git.

# Running the app

Fire up a server and try it all out:

    $ docker-compose up
    
Visit <http://127.0.0.1:3000>

# Main areas of functionality

## Search

To run test searches, you will need a working Bing API key. You can request one from Bing, or ask a friendly coworker. Add the key to `config/secrets.yml`

## Creating a new local admin account
[Login.gov](https://login.gov) is used for authentication.

To create a new local admin account we will need to:
1. Create an account on Login's sandbox environment.
2. Get the Login sandbox private key from a team member.
3. Add an admin user to your local app.

#### 1. Login sandbox
[Create an account](https://idp.int.identitysandbox.gov/sign_up/enter_email) on Login's sandbox environment. This will need to be a valid email address that you can get emails at. You'll receive a validation email to set a password and secondary authentication method.

#### 2. Get the Login sandbox private key
Ask your team members for the current `config/logindotgov.pem` file. This private key will let your local app complete the handshake with the Login sandbox servers.

#### 3. Add a new admin user to your local app
Open the rails console, add a new user with the matching email.
```
u = User.where(email: 'your-real-name+search-local@gsa.gov').first_or_initialize
u.assign_attributes( contact_name: 'admin',
                     first_name: 'search',
                     last_name: 'admin',
                     default_affiliate: Affiliate.find_by_name('usagov'),
                     is_affiliate: true,
                     organization_name: 'GSA',
                   )

u.approval_status = 'approved'
u.is_affiliate_admin = true
u.save!
```

You should now be able to login to your local instance of search.gov.

## Admin
Your user account should have admin priveleges set. Now go here and poke around.

<http://127.0.0.1:3000/admin>

## Asynchronous tasks
Several long-running tasks have been moved to the background for processing via Resque. Resque workers and the resque-web interface can be run automatically via `docker-compose up`. 

1. Visit the resque-web sinatra app at <http://0.0.0.0:5678/overview> to inspect queues, workers, etc.

1. In your admin center, [create a type-ahead suggestion (SAYT)](http://localhost:3000/admin/sayt_suggestions) "delete me". Now [create a SAYT filter](http://localhost:3000/admin/sayt_filters) on the word "delete".

1. You should see log lines indicating that a Resque worker has processed a `ApplySaytFilters` job:

`resque-workers_1  | *** Running before_fork hooks with [(Job{primary_low} | ApplySaytFilters | [])]`

At this point, you should see the queue empty in Resque web, and the suggestion "delete me" should be gone from the [sayt_suggestions table](http://localhost:3000/admin/sayt_suggestions).

### Queue names & priorities
Each Resque job runs in the context of a queue named 'primary' with priorities assigned at job creation time using the resque-priority Gem.
We have queues named :primary_low, :primary, and :primary_high. When creating a new
background job model, consider the priorities of the existing jobs to determine where your jobs should go. Things like fetching and indexing all
Odie documents will take days, and should run as low priority. But fetching and indexing a single URL uploaded by an affiliate should be high priority.
When in doubt, just use Resque.enqueue() instead of Resque.enqueue_with_priority() to put it on the normal priority queue.

### Scheduled jobs
We use the [resque-scheduler](https://github.com/resque/resque-scheduler) gem to schedule delayed jobs. Use [ActiveJob](http://api.rubyonrails.org/classes/ActiveJob/Core/ClassMethods.html)'s `:wait` or `:wait_until` options/ph to enqueue delayed jobs, or schedule them in `config/resque_schedule.yml`.

Example:

1. Schedule a delayed job: `SitemapMonitorJob.set(wait: 5.minutes).perform_later`

1. Check the 'Delayed' tab in [Resque web](http://0.0.0.0:5678/delayed) to see your job.

# Performance
We use New Relic to monitor our site performance, especially on search requests. If you are doing something around search, make
sure you aren't introducing anything to make it much slower. If you can, make it faster.

You can configure your local app to send metrics to New Relic.

1. Edit `config/secrets.yml` changing `enabled` to true and adding your name to `app_name` in the `newrelic` section

1. Edit `config/secrets.yml` and set `license_key` to your New Relic license key in the `newrelic_secrets` section

1. Run mongrel/thin

1. Run a few representative SERPs with news items, gov boxes, etc

1. Visit http://localhost:3000/newrelic

1. The database calls view was the most useful one for me. How many extra database calls did your feature introduce? Yes, they are fast, but at 10-50 searches per second, it adds up.

You can also turn on profiling and look into that (see https://newrelic.com/docs/general/profiling-ruby-applications).

### Additional developer resources
* [Local i14y setup](https://github.com/GSA/usasearch/blob/master/README_I14Y.markdown)