# USASearch Info

## Rails

If you have no experience with Ruby on Rails, this is not the document for you. This README assumes you already have a
working development environment for Rails up and running, including the database drivers.

## Ruby

You will need Ruby 1.8.7. Verify that your path points to the correct version of Ruby:

    lappy:usasearch loren$ ruby -v
    ruby 1.8.7 (2009-06-12 patchlevel 174) [i686-darwin10]
    lappy:usasearch loren$ which ruby
    /opt/local/bin/ruby

You will need to install rubygems 1.3.5 (1.3.6 generates deprecation warnings) and set up your gem sources:

    lappy:usasearch loren$ gem -v
    1.3.5
    lappy:usasearch loren$ which gem
    /opt/local/bin/gem
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

## Solr

We're using Solr for fulltext search. You might need to install these gems separately due to a Catch-22 with the Rake gem installer.

    sudo gem install sunspot --version '=1.1.0'
    sudo gem install sunspot_rails --version '=1.1.0'

You can start/stop/reindex Solr like this:

    rake sunspot:solr:start
    rake sunspot:solr:stop
    rake sunspot:solr:run
    rake sunspot:solr:reindex

If you are upgrading from a previous version of Sunspot/Solr (typically, this would be from Sunspot 0.11.5 and Solr 1.3 to Sunspot 1.1.0 and Solr 1.4), then you should take the following steps:

    rake sunspot:solr:stop
    rake sunspot:solr:stop RAILS_ENV=test
    git pull
    sudo gem install sunspot --version '=1.1.0'
    sudo gem install sunspot_rails --version '=1.1.0'
    rake sunspot:solr:start
    rake sunspot:solr:start RAILS_ENV=test
    rake sunspot:solr:reindex
    rake sunspot:solr:reindex RAILS_ENV=test

## Gems

You should be able to get all the rest of the gems needed for this project like this:

    sudo gem install cucumber hoptoad_notifier rspec rspec-rails capistrano capistrano-ext ruby-debug
    sudo rake gems:install
    sudo rake gems:install RAILS_ENV=test
    sudo rake gems:install RAILS_ENV=cucumber

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

    script/cucumber

# Code Coverage

We track test coverage of the codebase over time, to help identify areas where we could write better tests and to see when poorly tested code got introduced.

To show the coverage on the existing codebase, do this:

    rake rcov:all

Then to view the report, open `coverage/index.html` in your favorite browser.

You can click around on the files that have < 100% coverage to see what lines weren't exercised.

Make sure you commit any changes to the coverage directory back to git.

# Running it

Fire up a server and try it all out:

    script/server

# Main areas of functionality

## Search

<http://127.0.0.1:3000>

You should be able to type in 'taxes' and get search results.

Now populate your Faqs and Forms tables with files you can download from Github here:
<https://github.com/loren/usasearch/downloads>

    rake usasearch:gov_form:load[form_file_name]
    rake usasearch:faq:load[faq_file_name]

Now re-run your search for taxes and you should see more content.

## Affiliate accounts
Get yourself a user account

<http://127.0.0.1:3000/account>

Create an affiliate for yourself called 'foo', and put in a simple header/footer like H1's or something.
Re-run your 'taxes' search and add '&affiliate=foo' to the HTTP request.

## Analytics
If you are looking at the analytics functionality, it helps to have some sample data in there. This will populate your
development database with a month's worth of data for 100 query terms:

    rake usasearch:create_dummy_analytics_data DAYS=30 WORDCOUNT=100

Give your user account priveleges to access analytics (and admin while you are at it). Here's how with script/console:

    user = User.last
    user.update_attribute(:is_analyst, true)
    user.update_attribute(:is_affiliate_admin, true)

Check it out here:

<http://127.0.0.1:3000/analytics>

## Admin
Your user account should have admin priveleges set. Now go here and poke around.

<http://127.0.0.1:3000/admin>

Create a Spotlight (hint: use the template to get started). For keywords, put in 'taxes'.
Now re-run that taxes search again and you should see content above the search results.

# Contributing Code

1. Pick the next story off the top of the queue on Tracker and make sure you understand the intent behind it. Click the "Start" button so nobody else starts working on it. But before you click "Start", do you have a firm idea of what you will need to do in order to clck "Finished"?

2. Make sure you have the latest code:

        git pull

3. Write acceptance tests in rspec and/or cucumber that will specify whether the feature is implemented properly or not.

4. Write the minimal amount of code needed to make those tests pass

5. Run regression tests to make sure all prior functionality still passes tests

        rake spec
        script/cucumber

5. If you did any work with web forms, check for any XSS or SQL Injection vulnerabilities with the Firefox plugins from Seccom labs (http://labs.securitycompass.com/index.php/exploit-me/).

6. Check in code to your local git repo (use `git status` and `git add` until everything is staged):

        git commit

7. Push code up to the origin

        git push

8. Problems doing the push? Someone else may have checked in code since your last pull, so

        git pull
        rake spec
        script/cucumber
        git push

9. Mark story as "Finished" on Tracker. This means you are done testing/coding.

10. Deploy to demo

        cap deploy

11. Mark story as "Delivered". This means it's ready and visible for acceptance testing on the demo environment. Add an acceptance test in the story comments so someone else can easily verify what you have done.

12. Goto Step 1

# Using Labs
From time to time, a new feature will require testing and feedback from those outside of our development group.  We do not want to push experimental changes to our staging server, which is used for acceptance testing.  Instead, we have create a 'labs' deployment that is available for previewing experimental features.  The labs site is available at http://labs.searchdemo.usa.gov.  If that URL is not available, modify your /etc/hosts file to map the IP address of the searchdemo.usa.gov to labs.searchdemo.usa.gov.

In order to begin developing for the labs branch, you'll need to make sure that no one else is using the branch, or that you are at least in touch with those that are using it.  If the branch has been out of use for a while, it will probably be easier to remove the contents of the remote labs branch and start with a fresh version of the current code.  To remove the remote branch:

      git push origin :labs
      
Make sure to check that no one is using the labs branch before doing this, otherwise you'll delete their work!  Now, checkout a new local branch called labs, and push it up as a new remote branch:

      git checkout -b labs
      git push origin labs
      
If you want to begin using the labs branch as it is (for example, if you're working with someone else and they have already created the remote labs branch), you'll need to begin tracking the remote branch:

      git branch --track labs origin/labs
      
Now you can checkout the labs branch locally

      git checkout labs
      
and work together with other developers.
      
You are now ready to begin developing on the labs branch.  You'll probably want to branch off the labs branch itself if you're working on a big feature, and merge your changes into the labs branch.

When you are ready to deploy your experimental features on the labs.searchdemo.usa.gov site, push your latest commits up to the remote labs branch:

    git push origin labs
    
and do a deploy of the labs stage:

    cap labs deploy

Your experimental features are now on labs.searchdemo.usa.gov!  When your experimental features have been completed, and you're ready to merge them into the master branch so they can be deployed on searchdemo for acceptance testing, just treat your labs branch as your would any other feature branch:  rebase off of master, checkout master, and merge your changes into master.

Note:  when working with the labs branch, it's your responsibility to keep it in sync with master; if you don't rebase labs on master frequently, it's possible that your branch will become very different from master, making the process of merging your experimental features back into the master branch a real hassle.  It is advisable to rebase on master regularly:

      git checkout master
      git pull
      git checkout labs
      git rebase master

This will keep your labs branch in sync with the master branch, so when you're finished your experimental features, they'll integrate easily with the master branch.