# USASearch Info

## Rails

If you have no experience with Ruby on Rails, this is not the document for you. This README assumes you already have a
working development environment for Rails up and running, including the database drivers.

## Ruby

You will need Ruby Enterprise Edition 1.8.7. Verify that your path points to the correct version of Ruby:

    lappy:usasearch loren$ ruby -v
    ruby 1.8.7 (2011-02-18 patchlevel 334) [i686-darwin10.7.0], MBARI 0x6770, Ruby Enterprise Edition 2011.03
    lappy:usasearch loren$ which ruby
    /Users/loren/.rvm/rubies/ree-1.8.7-2011.03/bin/ruby

You will need to install the latest rubygems and set up your gem sources:

    gem install rubygems-update
    update_rubygems
    lappy:usasearch loren$ gem -v
    1.6.2
    lappy:usasearch loren$ which gem
    /Users/loren/.rvm/rubies/ree-1.8.7-2011.03/bin/gem
    lappy:usasearch loren$ more ~/.gemrc
    ---
    gem: --no-ri --no-rdoc
    :benchmark: false
    :backtrace: false
    :update_sources: true
    :verbose: true
    :bulk_threshold: 1000
    :sources:
    - http://gems.github.com
    - http://gems.rubyforge.org/
    - http://gemcutter.org

## Gems

For Rails 3, we use bundler; you should be able to get all the rest of the gems needed for this project like this:

    gem install bundler
    bundle install

## Solr

We're using Solr for fulltext search.

You can start/stop/reindex Solr like this:

    rake sunspot:solr:start
    rake sunspot:solr:stop
    rake sunspot:solr:run
    rake sunspot:solr:reindex

## Redis

We're using the Redis key-value store for caching and for queue workflow via Resque. Download and install the Redis server:

<http://redis.io/download>

# Database

The database.yml file assumes you have a local database server up and running (preferably MySQL >= 5.0.85), accessible from user 'root' with no password.

Create and setup your development and test databases:

    rake db:create
    rake db:create RAILS_ENV=test
    rake db:schema:load
    rake db:test:prepare

# Tests

These require a Solr server to be spun up.

    rake sunspot:solr:start RAILS_ENV=test

Make sure the unit tests and functional tests run:

    rake spec

Make sure the integration tests run.

    rake cucumber

# Code Coverage

We track test coverage of the codebase over time, to help identify areas where we could write better tests and to see when poorly tested code got introduced.

To show the coverage on the existing codebase, do this:

    rake rcov:all

Then to view the report, open `coverage/index.html` in your favorite browser.

You can click around on the files that have < 100% coverage to see what lines weren't exercised.

Make sure you commit any changes to the coverage directory back to git.

# Running it

Fire up a server and try it all out:

    rails server
or

    rails s

# Main areas of functionality

## Search

<http://127.0.0.1:3000>

You should be able to type in 'taxes' and get search results.

Now populate your Faqs and Forms tables with files you can download from Github here:
<https://github.com/loren/usasearch/downloads>

    rake usasearch:gov_form:load[form_file_name]
    rake usasearch:faq:load[faq_file_name]

Now re-run your search for taxes and you should see more content.

If you are interested in helath related data, you can also load MedLinePlus data
from the XML retrieved from the MedLine website (see doc/medline for more details).

    rake usasearch:medline:update

## Affiliate accounts
Get yourself a user account

<http://127.0.0.1:3000/account>

Create an affiliate for yourself called 'foo', and put in a simple header/footer like H1's or something.
Re-run your 'taxes' search and add '&affiliate=foo' to the HTTP request.

## Analytics
If you are looking at the analytics functionality, it helps to have some sample data in there. This will populate your
development database with a month's worth of data for 100 query terms:

    rake usasearch:create_dummy_analytics_data DAYS=30 WORDCOUNT=100

Give your user account priveleges to access analytics (and admin while you are at it). Here's how with rails console:

    user = User.last
    user.update_attribute(:is_analyst, true)
    user.update_attribute(:is_affiliate_admin, true)

Check it out here:

<http://127.0.0.1:3000/analytics>

## Admin
Your user account should have admin priveleges set. Now go here and poke around.

<http://127.0.0.1:3000/admin>

## Asynchronous tasks
Several long-running tasks have been moved to the background for processing via Resque. Here is how to see this in
action on your local machine, assuming you have installed the Redis server.

1. Run the redis-server

    % redis-server

1. Launch the Sinatra app to see the queues and jobs

    % resque-web

1. In your app, assuming you have at least one affiliate in your development database, make an affiliate broadcast:

    <http://localhost:3000/admin/affiliate_broadcasts/new>

1. Look in the Resque web queue to see the job enqueued.

1. Start a Resque worker to run the job:

    % QUEUE=* rake environment resque:work

At this point, you should see the queue empty in Resque web, and some email-like output in your development log.

### Queue names & priorities
Each Resque job runs in the context of a named queue. We have queues named :low, :medium, :high, and :urgent. When creating a new
background job model, consider the priorities of the existing jobs to determine where your jobs should go. When in doubt, use :medium.

# Working on Stories

1. Pick the next story off the top of the queue on Tracker and make sure you understand the intent behind it. Click the "Start" button so nobody else starts working on it. But before you click "Start", do you have a firm idea of what you will need to do in order to clck "Finished"? How will you know when you are done?

1. For user-facing content (e.g., Search Engine Results Pages [SERPs]), you'll want to raise these questions with the story owner:
    * How should this feature behave for Spanish-locale traffic? Is there any localized text I will need?
    * How should this feature behave for affiliate traffic?
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

        rake spec
        rake cucumber

    The entire test suite should always be 100% green. If anything fails at any time, it's the new top priority to fix it, and no developer should check in code on top of broken tests.

1. Now that you are green, have a look through all your changes to make sure everything that is in there needs to be there. Can you delete any lines of code? Can you refactor anything?

1. If you did any work with web forms, check for any XSS or SQL Injection vulnerabilities with the Firefox plugins from Seccom labs (http://labs.securitycompass.com/index.php/exploit-me/). We have a third party scan our site monthly for XSS vulnerabilities (among other things), and if they discover XSS vulnerabilities before we do, it could risk our [C&A](http://en.wikipedia.org/wiki/Certification_and_Accreditation) standing.

1. Check in code to your local git repo (use `git status` and `git add` until everything is staged):

        git commit

    It's easier for other developers to see the work you did for a story in a single commit, rather than spread out over a bunch of checkpoints. It's a good idea to do many local commits while working on a story, and then roll those up into a single commit with Git either by continually amending your prior commit, or by doing an interactive rebase and squashing everything. The exception to this is the 'coverage/' directory that gets updated with 'rcov'. That's better off in its own commit, so your code changes aren't lost among several hundred auto-generated HTML files.

    By using the [special syntax](https://www.pivotaltracker.com/help/api?version=v3#scm_post_commit_message_syntax) in the commit message, you can associate the commit with one or more Tracker story IDs and (optionally) a state change for the story.

1. Run RCov to make sure all your code gets touched by a test, at least:

        rake rcov:all
        open coverage/index.html
        git add coverage
        git ci -am "updated rcov coverage report"

1. Push code up to the origin. Before you do this, remember that you are committing to the master branch, and future production deployments will ideally be grabbing everything from this branch. For this reason, you'll only want to push to origin/master code that is pretty much ready for production deployment, or could be ready fairly soon, say after a day or two of iterating on feedback. One good rule of thumb is the "Washington Post" test, as it's a scenario that is raised fairly often. Before pushing to origin, ask yourself, "If this work I've just done somehow finds its way into a Washington Post article with a screenshot, will everyone be OK with that?". If so, then....

        git push

1. Problems doing the push? Someone else may have checked in code since your last pull, so

        git pull
        rake spec
        rake cucumber
        git push

1. Mark story as "Finished" on Tracker. This means you are done testing/coding.

1. Deploy to demo (or have someone with VPN access deploy for you).

        cap deploy

1. Mark story as "Delivered". This means it's ready and visible for acceptance testing on the demo environment. Add an acceptance test in the story comments so someone else can easily verify what you have done, including ways to highlight various scenarios and corner cases (e.g., "By searching on 'beef recalls', you can see how the UI looks when there are many recalls listed...", or "Go to this URL on staging to see how it behaves in Spanish for affiliates").

1. Goto Step 1
