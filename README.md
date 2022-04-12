# Search-gov Info

## Code Status

 [![Build Status](https://circleci.com/gh/GSA/search-gov.svg?style=svg)](https://circleci.com/gh/GSA/search-gov)
 [![Maintainability](https://api.codeclimate.com/v1/badges/fd0577360749c9b3d166/maintainability)](https://codeclimate.com/github/GSA/search-gov/maintainability)

## Contributing to search-gov
Read our [contributing guidelines](https://github.com/GSA/search-gov/blob/master/CONTRIBUTING.md). 

## Dependencies

### Ruby

Use [RVM](https://rvm.io/) to install the version of Ruby specified in [.ruby-version](/.ruby-version). 

### Docker

The required services (Redis, MySQL, etc.) can all be installed and run using [Docker](https://www.docker.com/get-started). If you prefer to install the services without Docker, see the [wiki](https://github.com/GSA/search-gov/wiki/Local-Installation-and-Management-of-dependencies). We recommend setting the max memory alloted to Docker to 4GB (in Docker Desktop, Preferences > Resources > Advanced). See [the wiki](https://github.com/GSA/search-gov/wiki/Docker-Command-Reference) for more documentation on basic Docker commands.
    
### Services

All the required services below can be run using [Docker Compose](https://docs.docker.com/compose/):

    $ docker compose up
    
Alternatively, run the services individually, i.e.:

    $ docker compose up redis

* [Elasticsearch](https://www.elastic.co/elasticsearch/) 6.8 - for full-text search and query analytics

We have configured Elasticsearch 6.8 to run on port [9268](http://localhost:9268/), and Elasticsearch 7.8 to run on [9278](http://localhost:9278/). (Currently, only 6.8 is used in production, but some tests run against both versions.) To check Elasticsearch settings and directory locations:

    $ curl "localhost:9268/_nodes/settings?pretty=true"
    $ curl "localhost:9278/_nodes/settings?pretty=true"
    
Some specs depend upon Elasticsearch having a valid trial license. A 30-day trial license is automatically applied when the cluster is initially created. If your license expires, you can rebuild the cluster by [rebuilding the container and its data volume](https://github.com/GSA/search-gov/wiki/Docker-Command-Reference/_edit#recreate-an-elasticsearch-cluster-useful-for-restarting-a-trial-license). 
    
    
* [Kibana](https://www.elastic.co/kibana) - Kibana is not required, but can be very useful for debugging Elasticsearch. Confirm Kibana is available for the Elasticsearch 6.8 cluster by visiting <http://localhost:5668>. Kibana for the Elasticsearch 7 cluster should be available on <http://localhost:5678>.

* [MySQL](https://dev.mysql.com/doc/refman/5.6/en/) 5.6 - database, accessible from user 'root' with no password
* [Redis](https://redis.io/) 5.0 - We're using the Redis key-value store for caching, queue workflow via Resque, and some analytics.
* [Tika](https://tika.apache.org/) - for extracting plain text from PDFs, etc. The [Tika REST server](https://cwiki.apache.org/confluence/display/TIKA/TikaServer) runs on <http://localhost:9998/>.

### Package Manager

We recommend using [Homebrew](https://brew.sh/) for local package installation on a Mac.

### Packages

Use the package manager of your choice to install the following packages:

* C++ compiler - required by the [cld3](https://github.com/akihikodaki/cld3-ruby) gem, which we use for language detection
* Google's [protocol buffers](https://developers.google.com/protocol-buffers/) - also required by the cld gem
* [Java Runtime Environment](https://www.java.com/en/download/)
* [ImageMagick](https://imagemagick.org/) - required by the Paperclip gem, used for image attachments
* [MySQL client](https://github.com/brianmario/mysql2#mac-os-x) - required by the mysql2 gem
* [V8](https://v8.dev/)

Example of installation on Mac using [Homebrew](https://brew.sh/):

    $ brew install gcc
    $ brew install protobuf
    $ brew install java
    $ brew install imagemagick
    $ brew install mysql@5.7
    $ brew install v8@3.15
    
Example of installation on Linux:

    $ apt-get install protobuf-compiler
    $ apt-get install libprotobuf-dev
    $ apt-get install imagemagick
    $ apt-get install default-jre
    $ apt-get install default-mysql-client

### Gems

Use [Bundler](https://bundler.io/) 2.3.8 to install the required gems:

    $ gem install bundler -v 2.3.8
    $ bundle install

Refer to [the wiki](https://github.com/GSA/search-gov/wiki/Gem-Installation-gotchas-and-solutions) to troubleshoot gem installation errors.

## Service credentials; how we protect secrets

The app does its best to avoid interacting with most remote services during the test phase through heavy use of the [VCR](/wiki/Editing-Recording-and-Re-recording-API-calls-with-VCR-(WIP)) gem.

Run this command to get a valid `secrets.yml` file that will work for running existing specs:

    $ cp config/secrets.yml.dev config/secrets.yml

If you find that you need to run specs that interact with a remote service, you'll need to put valid credentials into your `secrets.yml` file.

Anything listed in the `secret_keys` entry of that file will automatically be masked by VCR in newly-recorded cassettes.

## Database

Create and set up your development and test databases:

    $ rails db:setup
    $ rails db:test:prepare
     
### Indexes

You can create the USASearch-related indexes like this:

    $ rake usasearch:elasticsearch:create_indexes

You can index all the records from ActiveRecord-backed indexes like this:

    $ rake usasearch:elasticsearch:index_all[FeaturedCollection+BoostedContent]

If you want it to run in parallel using Resque workers, call it like this:

    $ rake usasearch:elasticsearch:resque_index_all[FeaturedCollection+BoostedContent]

Note that indexing everything uses whatever index/mapping/setting is in place. If you need to change the Elasticsearch schema first, do this:

    $ rake usasearch:elasticsearch:recreate_index[FeaturedCollection]

If you are changing a schema and want to migrate the index without having it be unavailable, do this:

    $ rake usasearch:elasticsearch:migrate[FeaturedCollection]

Same thing, but using Resque to index in parallel:

    $ rake usasearch:elasticsearch:resque_migrate[FeaturedCollection]

# Tests

Make sure the unit tests, functional and integration tests run:
    
    # Run the RSpec tests
    $ rspec spec/
    
    # Run the Cucumber integration tests
    $ cucumber features/
    
## Code Coverage

We require 100% code coverage. After running the tests (both RSpec & Cucumber), open `coverage/index.html` in your favorite browser to view the report. You can click around on the files that have < 100% coverage to see what lines weren't exercised.

## Circle CI

We use [CircleCI](https://circleci.com/gh/GSA/usasearch) for continuous integration. Build artifacts, such as logs, are available in the 'Artifacts' tab of each CircleCI build.


# Code Quality

We use [Rubocop](https://rubocop.org/) for static code analysis. Settings specific to search-gov are configured via [.rubocop.yml](.rubocop.yml). Settings that can be shared among all Search.gov repos should be configured via the [searchgov_style](https://github.com/GSA/searchgov_style) gem.

# Running the app

Fire up a server and try it all out:

    $ rails server
    
Visit <http://localhost:3000>

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
Your user account should have admin privileges set. Now go here and poke around.

<http://localhost:3000/admin>

## Asynchronous tasks
Several long-running tasks have been moved to the background for processing via Resque.

1. Visit the resque-web sinatra app at <http://localhost:3000/admin/resque> to inspect queues, workers, etc.

1. In your admin center, [create a type-ahead suggestion (SAYT)](http://localhost:3000/admin/sayt_suggestions) "delete me". Now [create a SAYT filter](http://localhost:3000/admin/sayt_filters) on the word "delete".

1. Look in the Resque web queue to see the job enqueued.

1. Start a Resque worker to run the job:

   `$ QUEUE=* rake environment resque:work`

1. You should see log lines indicating that a Resque worker has processed a `ApplySaytFilters` job:

`resque-workers_1  | *** Running before_fork hooks with [(Job{primary_low} | ApplySaytFilters | [])]`

At this point, you should see the queue empty in Resque web, and the suggestion "delete me" should be gone from the [sayt_suggestions table](http://localhost:3000/admin/sayt_suggestions).

### Queue names & priorities
Each Resque job runs in the context of a queue named 'primary' with priorities assigned at job creation time using the resque-priority Gem.
We have queues named :primary_low, :primary, and :primary_high. When creating a new
background job model, consider the priorities of the existing jobs to determine where your jobs should go. Things like fetching and indexing all
Odie documents will take days, and should run as low priority. But fetching and indexing a single URL uploaded by an affiliate should be high priority.
When in doubt, just use Resque.enqueue() instead of Resque.enqueue_with_priority() to put it on the normal priority queue.

(Note: newer jobs inherit from ActiveJob, using the resque queue adapter. We are in the process of migrating the older jobs to ActiveJob.)

### Scheduled jobs
We use the [resque-scheduler](https://github.com/resque/resque-scheduler) gem to schedule delayed jobs. Use [ActiveJob](http://api.rubyonrails.org/classes/ActiveJob/Core/ClassMethods.html)'s `:wait` or `:wait_until` options to enqueue delayed jobs, or schedule them in `config/resque_schedule.yml`.

Example:

1. In the Rails console, schedule a delayed job:

    `> SitemapMonitorJob.set(wait: 5.minutes).perform_later`

1. Run the resque-scheduler rake task:

    `$ rake resque-scheduler`

1. Check the 'Delayed' tab in [Resque web](http://localhost:3000/admin/resque/delayed) to see your job.

### Additional developer resources
* [Local i14y setup](https://github.com/GSA/search-gov/wiki/Setting-up-i14y-with-usasearch-for-development)
