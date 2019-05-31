# USASearch Info

## Code Status

 [![Build Status](https://circleci.com/gh/GSA/search-gov.svg?style=svg)](https://circleci.com/gh/GSA/search-gov)
 [![Maintainability](https://api.codeclimate.com/v1/badges/fd0577360749c9b3d166/maintainability)](https://codeclimate.com/github/GSA/search-gov/maintainability)

## Rails

If you have no experience with Ruby on Rails, this is not the document for you. This README assumes you already have a
working development environment for Rails up and running, including the database drivers.

## Ruby

You will need Ruby 2.3.8 Verify that your path points to the correct version of Ruby:

    devbox:usasearch
    $ ruby -v
    ruby 2.3.8p459 (2018-10-18 revision 65136) [x86_64-darwin16]

## Packages

The [cld3](https://github.com/akihikodaki/cld3-ruby) gem, which we use for language detection, depends on Google's
[protocol buffers](https://developers.google.com/protocol-buffers/) and
a C++ compiler:

    brew install gcc
    brew install protobuf

## Gems

For Rails 4, we use bundler; you should be able to get all the rest of the gems needed for this project like this:

    gem install bundler
    bundle install

## Service credentials; how we protect secrets

The app does its best to avoid interacting with most remote services during the test phase through heavy use of the [VCR](https://github.com/vcr/vcr) gem.

You should be able to simply run this command:

```
cp config/secrets.yml.dev config/secrets.yml
```

To get a valid `secrets.yml` file that will work for running existing specs.

If you find that you need to run specs that interact with a remote service, you'll need to put valid credentials into your `secrets.yml` file.

Anything listed in the `secret_keys` entry of that file will automatically be masked by VCR in newly-recorded cassettes.

## Database

Install MySQL 5.6.x using Homebrew:
```
$ brew update
$ brew search mysql
```
The output should include `mysql@5.6` listed under `Formulae`.
```
$ brew install mysql56
```

Follow the instructions provided by Homebrew during installation.

Add the following to your database server's my.cnf file (normally located at `/usr/local/etc/my.cnf`):

```
[mysqld]
innodb_strict_mode = ON
innodb_large_prefix = ON
innodb_file_format = Barracuda
```

Start or restart MySQL:
```
$ brew services start mysql56
```

You may need to reinstall the mysql2 gem if you changed your MySQL version:

    gem uninstall mysql2
    bundle install

Create and setup your development and test databases. The database.yml file assumes you have a local database server up and running (MySQL 5.6.x), accessible from user 'root' with no password.

    $ rake db:setup
    $ rake db:test:prepare

### Troubleshooting your database setup

Problems may arise if you have multiple versions of MySQL installed, or if you have installed MySQL via the OSX installer instead of or in addition to Homebrew. Below are some troubleshooting steps:

Verify that you are running the Homebrew-installed version of MySQL (as indicated by the `/usr/local/opt/mysql@5.6` directory):
```
$ ps -ef | grep mysql
  502 26965     1   0 12:23PM ??         0:00.04 /bin/sh /usr/local/opt/mysql@5.6/bin/mysqld_safe --bind-address=127.0.0.1 --datadir=/usr/local/var/mysql
```

Verify that Rails is using the Homebrew version:
```
$ rails db
```

The output should include:
```
Server version: 5.6.<x> Homebrew
```

It may also help to specify the Homebrew directories when reinstalling the `mysql2` gem:
```
$ gem uninstall mysql2
$ gem install mysql2 -v '0.3.11' --   --with-mysql-lib=$(brew --prefix mysql56)/lib   --with-mysql-dir=$(brew --prefix mysql56)   --with-mysql-config=$(brew --prefix mysql56)/bin/mysql_config   --with-mysql-include=$(brew --prefix mysql56)/include
```

## Asset pipeline

A few tips when working with asset pipeline:

* Ensure that your asset directory is in the asset paths by running the following in the console:

        y Rails.application.assets.paths

* Find out which file is served for a given asset path by running the following in the console:

        Rails.application.assets['relative_path/to_asset.ext']

## JAVA

Install Java 8.

    $ brew tap caskroom/versions

    $ brew cask install java8
    
## Elasticsearch

We're using [Elastic](http://www.elasticsearch.org/) v1.7.3 for fulltext search and query analytics.

On a Mac, Elasticsearch is easy to install by following these instructions:
  https://www.elastic.co/guide/en/elasticsearch/reference/1.7/_installation.html

To check settings and directory locations:

    $ curl "localhost:9200/_nodes/settings?pretty=true"

To change the defaults, like number of shards/replicas, edit this file:

    $ sudo vi /usr/local/Cellar/elasticsearch/1.7.3/config/elasticsearch.yml

    index.number_of_shards: 1
    index.number_of_replicas: 0

For the time being, add this to the end of the file to re-enable MVEL scripting for sandboxed languages like Groovy:

    script.disable_dynamic: false

You may need to re-install any plugins you were using locally:

    $ plugin -i elasticsearch/marvel/latest
    $ plugin -i polyfractal/elasticsearch-inquisitor
    $ plugin -i mobz/elasticsearch-head
    $ plugin -i elasticsearch/elasticsearch-cloud-aws/2.7.0

If you install Marvel, you probably don't want to monitor your local cluster, so add this to your `elastisearch.yml` file:

    marvel.agent.enabled: false

The default JVM heap is 256m with a max of 1g. You can increase it by editing your `~/Library/LaunchAgents/homebrew.mxcl.elasticsearch.plist` file like this:

    <dict>
      <key>ES_JAVA_OPTS</key>
      <string>-Xss200000</string>
      <key>ES_HEAP_SIZE</key>
      <string>4g</string>
      <key>ES_MAX_MEM</key>
      <string>4g</string>
    </dict>

Now restart it:

    $ launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.elasticsearch17.plist
    $ launchctl load ~/Library/LaunchAgents/homebrew.mxcl.elasticsearch17.plist

If you aren't using Homebrew to install and configure Elasticsearch, follow the [instructions](http://www.elasticsearch.org/download/) to download and run it.

### Indexes

You can create the USASearch-related indexes like this:

    rake usasearch:elasticsearch:create_indexes

You can index all the records from ActiveRecord-backed indexes like this:

    rake usasearch:elasticsearch:index_all[FeaturedCollection+BoostedContent]

If you want it to run in parallel using Resque workers, call it like this:

    rake usasearch:elasticsearch:resque_index_all[FeaturedCollection+BoostedContent]

Note that indexing everything uses whatever index/mapping/setting is in place. If you need to change the Elasticsearch schema first, do this:

    rake usasearch:elasticsearch:recreate_index[FeaturedCollection]

If you are changing a schema and want to migrate the index without having it be unavailable, do this:

    rake usasearch:elasticsearch:migrate[FeaturedCollection]

Same thing, but using Resque to index in parallel:

    rake usasearch:elasticsearch:resque_migrate[FeaturedCollection]

Install the [Inquisitor](https://github.com/polyfractal/elasticsearch-inquisitor) plugin to see how our analyzers look at text.

    http://localhost:9200/_plugin/inquisitor/#/analyzers

Install the [Head](http://mobz.github.io/elasticsearch-head/) plugin so you have a simple GUI for testing queries and looking at index data.

    http://localhost:9200/_plugin/head/

## Redis

We're using the Redis key-value store for caching, queue workflow via Resque, and some analytics. Download and install the Redis server:

<http://redis.io/download>
<http://redis.io/topics/quickstart>

Verify that redis-server is in your path

    $ which redis-server
    /opt/redis/bin/redis-server

## Imagemagick

We use Imagemagick to identify some image properties. It can also be installed with Homebrew on a Mac.

    $ brew install imagemagick

# Tests

We use poltergeist gem to test Javascript. This gem depends on PhantomJS.

Download and install PhantomJS:

<http://phantomjs.org/download.html>

It can also be installed with Homebrew on a Mac.

    $ brew tap homebrew/cask

    $ brew cask install phantomjs

If you see ```Error: The `brew link` step did not complete successfully``` when installing phantomjs, 

you may need to overwrite the symbolic link.
    
    $ brew link --overwrite phantomjs198

Make sure the unit tests, functional and integration tests run:

    rake

## Circle CI

We use [CircleCI](https://circleci.com/gh/GSA/usasearch) for continuous integration. Build artifacts, such as logs, are available in the 'Artifacts' tab of each CircleCI build.

# Code Coverage

We track test coverage of the codebase over time, to help identify areas where we could write better tests and to see when poorly tested code got introduced.

To show the coverage on the existing codebase, do this if you have not:

    rake

Then to view the report, open `coverage/index.html` in your favorite browser.

You can click around on the files that have < 100% coverage to see what lines weren't exercised.

Make sure you commit any changes to the coverage directory back to git.

# Running the app

Fire up a server and try it all out:

    rails server
or

    rails s

# Main areas of functionality

## Search

<http://127.0.0.1:3000>

You should be able to type in 'taxes' and get search results.

If you are interested in helath related data, you can also load MedLinePlus data
from the XML retrieved from the MedLine website (see doc/medline for more details).

    rake usasearch:medline:load

## Affiliate accounts
The database is seeded with a user that has super admin privileges:
    
    email: admin@email.gov
    password: test1234!

You can also create a user account using a bogus .gov or .mil email address:

<http://127.0.0.1:3000/login>

Look for the `email_verification_token` in your rails server stdout and open the verification link in your favorite browser:
    
    http://127.0.0.1:3000/email_verification/<email_verification_token>

Create an affiliate for yourself called 'foo', and put in a simple header/footer like H1's or something.
Re-run your 'taxes' search and add '&affiliate=foo' to the HTTP request.

## Analytics
Give your user account admin privileges. Here's how with rails console:

    user = User.last
    user.update_attribute(:is_affiliate_admin, true)

Check it out here:

<http://127.0.0.1:3000/admin>

## Admin
Your user account should have admin priveleges set. Now go here and poke around.

<http://127.0.0.1:3000/admin>

## Asynchronous tasks
Several long-running tasks have been moved to the background for processing via Resque. Here is how to see this in
action on your local machine, assuming you have installed the Redis server.

1. Run the redis-server

    % redis-server

1. Launch the Sinatra app to see the queues and jobs

    % resque-web ./lib/setup_resque.rb

1. In your admin center, create a SAYT suggestion "delete me". Now create a SAYT filter on the word "delete":

    <http://localhost:3000/admin/>

1. Look in the Resque web queue to see the job enqueued.

1. Start a Resque worker to run the job:

    % QUEUE=* rake environment resque:work

At this point, you should see the queue empty in Resque web, and the suggestion "delete me" should be gone from the sayt_suggestions table.

### Queue names & priorities
Each Resque job runs in the context of a queue named 'primary' with priorities assigned at job creation time using the resque-priority Gem.
We have queues named :primary_low, :primary, and :primary_high. When creating a new
background job model, consider the priorities of the existing jobs to determine where your jobs should go. Things like fetching and indexing all
Odie documents will take days, and should run as low priority. But fetching and indexing a single URL uploaded by an affiliate should be high priority.
When in doubt, just use Resque.enqueue() instead of Resque.enqueue_with_priority() to put it on the normal priority queue.

### Scheduled jobs
We use the [resque-scheduler](https://github.com/resque/resque-scheduler) gem to schedule delayed jobs. Use [ActiveJob](http://api.rubyonrails.org/classes/ActiveJob/Core/ClassMethods.html)'s `:wait` or `:wait_until` options to enqueue delayed jobs, or schedule them in `config/resque_schedule.yml`.

Example:

1. Schedule a delayed job:

`MyJob.set(wait: 30.seconds).perform_later(args)`

2. Run the resque-scheduler rake task:

`rake resque:scheduler`

3. Check the 'Scheduled' tab in Resque web (see above) to see your job.

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

# Writing Stories
1. Titles should include a 'should' or 'should not' statement.

1. Try to follow the 'As a ..., I want to ..., because/so that...' format for the description to make sure we're starting from the same page. Example:  “As a developer, I would like to have story descriptions written in a consistent format, so that I can understand what is being requested.” 

# Working on Stories

1. Pick the next story off the top of the queue on Tracker and make sure you understand the intent behind it. Click the "Start" button so nobody else starts working on it. But before you click "Start", do you have a firm idea of what you will need to do in order to click "Finished"? How will you know when you are done?

1. For user-facing content (e.g., Search Engine Results Pages [SERPs]), you'll want to raise these questions with the story owner:
    * How should this feature behave for non-English traffic? Is there any localized text I will need?
    * Should this feature have a mobile web implementation?
    * Is there an admin component to this feature?
    * Does the usage of this feature need to be tracked?

1. Make sure you are comfortable with the number of story points associated with the feature. As a rule of thumb, zero points means you can knock it out in an hour or less, one point means a half-day or so, two points is a full day or so of work, and four points is a few days. Generally we decompose eight point stories (epics) into smaller stories. If someone already assigned points to the story and you disagree, then change it to reflect your viewpoint.

1. Now that you have a good idea of how to get started and how to be finished, make sure you have the latest code:

        git pull

1. Some people like to create a story branch so that all the work for a story is happening somewhere outside of master. For quick 1-point stories, this isn't so important, but if you happen to be working on a larger story that gets sidelined and need to commit something else to master, having story branches makes it easy to keep track of everything.

1. Write acceptance tests in rspec and/or cucumber that will specify whether the feature is implemented properly or not.

1. Write the minimal amount of code needed to make those tests pass.

1. Run regression tests to make sure all prior functionality still passes tests

        rake

    The entire test suite should always be 100% green. If anything fails at any time, it's the new top priority to fix it, and no developer should check in code on top of broken tests.

1. Now that you are green, have a look through all your changes to make sure everything that is in there needs to be there.

    For using-facing story, does it work across browsers? (IE7 and up on Admin Center, IE8 and up on SERPs)
    
    Can you delete any lines of code? Can you refactor anything?
    
    Check for issues in your changes using [Code Climate](https://codeclimate.com/repos/5266dfe9f3ea0018fa0523e0/feed). Follow the [instructions from Code Climate](https://github.com/codeclimate/codeclimate/blob/master/README.md) to install the Code Climate CLI to run those tests locally.

1. If you did any work with web forms, check for any XSS or SQL Injection vulnerabilities with the Firefox plugins from Seccom labs (http://labs.securitycompass.com/index.php/exploit-me/). We have a third party scan our site monthly for XSS vulnerabilities (among other things), and if they discover XSS vulnerabilities before we do, it could risk our [C&A](http://en.wikipedia.org/wiki/Certification_and_Accreditation) standing.

1. Create a Pull Request

1. Once code is reviewed and pushed to staging, you may then mark story as "Delivered". This means it's ready and visible for acceptance testing on the demo environment. Add an acceptance test in the story comments so someone else can easily verify what you have done, including ways to highlight various scenarios and corner cases (e.g., "By searching on 'beef recalls', you can see how the UI looks when there are many recalls listed...", or "Go to this URL on staging to see how it behaves in Spanish for affiliates").

1. Goto Step 1

<!---

1. Check in code to your local git repo (use `git status` and `git add` until everything is staged):

        git commit

    It's easier for other developers to see the work you did for a story in a single commit, rather than spread out over a bunch of checkpoints. It's a good idea to do many local commits while working on a story, and then roll those up into a single commit with Git either by continually amending your prior commit, or by doing an interactive rebase and squashing everything. The exception to this is the 'coverage/' directory that gets updated with 'rcov'. That's better off in its own commit, so your code changes aren't lost among several hundred auto-generated HTML files.

    By using the [special syntax](https://www.pivotaltracker.com/help/api?version=v3#scm_post_commit_message_syntax) in the commit message, you can associate the commit with one or more Tracker story IDs and (optionally) a state change for the story.

1. Make sure all your code gets touched by a test, at least:

        open coverage/rcov/index.html

1. Run assets:precompile before pushing to origin if you modified one or more assets. Verify your generated assets in the public/assets directory. Always clean your public/assets directory after running assets:precompile. You will not see changes to your code in app/assets if the same asset exists in public/assets.

        rake assets:precompile

1. Push code up to the origin. Before you do this, remember that you are committing to the master branch, and future production deployments will ideally be grabbing everything from this branch. For this reason, you'll only want to push to origin/master code that is pretty much ready for production deployment, or could be ready fairly soon, say after a day or two of iterating on feedback. One good rule of thumb is the "Washington Post" test, as it's a scenario that is raised fairly often. Before pushing to origin, ask yourself, "If this work I've just done somehow finds its way into a Washington Post article with a screenshot, will everyone be OK with that?". If so, then....

        git push

1. Problems doing the push? Someone else may have checked in code since your last pull, so

        git pull
        rake
        git push

1. Mark story as "Finished" on Tracker. This means you are done testing/coding.

1. Deploy to demo (or have someone with VPN access deploy for you).

        cap deploy

-->


