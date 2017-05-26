Course Github Org Tool
================

[![Build Status](https://travis-ci.org/project-anacapa/course-github-org-tool.svg?branch=master)](https://travis-ci.org/project-anacapa/course-github-org-tool)
[![Code Climate](https://codeclimate.com/github/project-anacapa/course-github-org-tool/badges/gpa.svg)](https://codeclimate.com/github/project-anacapa/course-github-org-tool)
[![Coverage Status](https://coveralls.io/repos/github/project-anacapa/course-github-org-tool/badge.svg?branch=master)](https://coveralls.io/github/project-anacapa/course-github-org-tool?branch=master)
[![Issue Count](https://codeclimate.com/github/project-anacapa/course-github-org-tool/badges/issue_count.svg)](https://codeclimate.com/github/project-anacapa/course-github-org-tool)
[![Inline docs](http://inch-ci.org/github/project-anacapa/course-github-org-tool.svg?branch=master)](http://inch-ci.org/github/project-anacapa/course-github-org-tool)

This tool is a first attempt at a MVP for allowing students to self-enroll in a GitHub Organization associated with a course, provided:

* Their school email address (e.g. 'cgaucho@umail.ucsb.edu') appears as a verified email address on their GitHub account
* That email is in the course roster for the course (uploaded by the instructor)

It also provides an interface for instructors to view which of their students have or have not enrolled in the GitHub Organization for the course, provided that the students have logged in to the application OR the application knows about the students' GitHub usernames.

Finally, this tool is the starting point for future planned features including:
1. A means for instructors to manage student assignments
    * Instructors will be able to set up starter code, and students will be able to automatically create repos with the correct naming convention for single work, pair, or team work.
    * This is similar to the functionality of [Github Classroom], but has the added benefit that (a) student's submissions are tied back to their official enrollment in the class by school email and, optionally,student id and (b) only students officially enrolled in the class can get access to self-signup into the organization.
    * There will be a feature that allows instructors/TAs to gather all student submissions into a single directory structure for off line grading, or other processing.
2. A means for instructors to give feedback on student assignments.
3. Auto grader features that replace the submit.cs autograder deployed at UCSB.

Deploying on Heroku
===================

To deploy this app on Heroku, you will need

1. A Heroku account.  The "free tier" is sufficient.

1. A github organization for your course, to which the instructor has owner access.  We will refer to that organization by the example name `UCSB-CS99-S15` in these instructions.     
    
1. Values for six environment variables that authenticate the application to github in various ways.  We'll explain how to set up each of these in just a moment.  Each of these takes only a minute or two to obtain.   Here's a list of them for reference&mdash;we'll explain how to get each of them below.
    * GIT_PROVIDER_URL
    * OMNIAUTH_STRATEGY
    * OMNIAUTH_PROVIDER_KEY
    * OMNIAUTH_PROVIDER_KEY
    * MACHINE_USER_NAME
    * MACHINE_USER_KEY

1. Optionally, a name for your application.  If you don't choose one, heroku will choose one for you such as `mashed-potatoes-85352`.  You may want to think of a better one in advance, such as `ucsb-cs99-s15-signup` or `ucsd-cse-spis-2017-signup`.  But that's up to you.

Once you have those four things ready, you can deploy to Heroku with a few mouse clicks.

# Steps to take

## Step 1: Generate your `OMNIAUTH_PROVIDER_KEY` and `OMNIAUTH_PROVIDER_KEY`

Before you do this step, you will need:

* Your course github organization name
* The name of the heroku app you are going to create

First: while signed in as a github user that has owner access to the course organization (e.g. `UCSB-CS99-S15`), and navigate to the "Register a new OAuth application" screen.  This is  accessed via "Settings", then under "Developer Settings", the tab called "OAuth Applications", and then the "Register a new application" button.  The URL is likely of the form: <https://github.com/organizations/UCSB-CS99-S15/settings/applications/new>

* OMNIAUTH_STRATEGY will be one of `github` or `github_enterprise`. This corresponds to whether you are using `github.com` (choosing `github`) or
    a custom enterprise github instance (choosing `github_enterprise`)
  * If you choose `github_enterprise`, you should also set the GIT_PROVIDER_URL to be the domain name of your enterprise github instance
    * For example, this might be `github.DOMAIN.com` (in our case, `github.ucsb.edu`)
    
* OMNIAUTH_PROVIDER_KEY and OMNIAUTH_PROVIDER_SECRET correspond to the "Github OAuth Client Id" and
    "Github OAuth Client Secret".  These allow the application to authenticate to Github.    
    These can be associated with a github user, or with a github organization.  Set these up here,
    for example: <https://github.com/settings/applications/new>  

    You'll be asked for these pieces of information
    
    * `Application name`: Something like: `ucsb-cs99-s15-signup`
    
        You can enter anything you like, but you should choose something that will be meaningful
        to the students enrolling in your course.  They'll be asked whether they trust this application with their
        github credentials.   
        
        
    * Homepage URL: This should be `https://appname.herokuapp.com` (e.g. `https://ucsb-cs99-s15-signup.herokuapp.com`, not
        literally `appname`.)

    * Application description: Optional, but here you could put something like "Registration for github accounts
        for Prof. Smith's CS99 Course at Narnia University."
        
    * Authorization callback URL: Should be: `https://<<your-url>>/auth/github/callback`, where `<<your-url>>` is, for example, `ucsb-cs99-s15-signup.herokuapp.com`.   It is important to get this exact, or the OAuth signin will not work properly.

Once you enter all of this, you'll get back a Github-Client-Id, and a Github-Client-Secret.  Keep this window open so that you can copy these values in for OMNIAUTH_PROVIDER_KEY and OMNIAUTH_PROVIDER_SECRET when you get to step 3 (deploying on Heroku).

## Step 2: Create your `MACHINE_USER_NAME` and `MACHINE_USER_KEY`

You now need to create these two values:

* MACHINE_USER_NAME  This is the userid of a github "machine user" as explained
    here:     <https://developer.github.com/guides/managing-deploy-keys/#machine-users>.   
    This user is the the user that acts on
    behalf of the application.   One of the first steps in application setup is to give this "machine user" owner access
    to the organization so that it can add students to the organization on behalf of the instructor (this allows us to
    limit the scope of what the application has access to---only a single organization rather than everything the
    instructor's account could potentially do.)

    To set one of these up, simply log out of github, and create a brand new github user.  When prompted for an email,
    you'll find that if you use an email that is already associated with a github account, you'll get an error.  To
    get around this, add a tag to your email, as in this example: instead of `jsmith@gmail.com`, use `jsmith+github-mu@gmail.com` or instead of `pconrad@cs.ucsb.edu`, use `pconrad+github-tool@cs.ucsb.edu`.

* MACHINE_USER_KEY.  This is a "personal access token" for the machine user.  While logged in to github "as the machine user", access this
    item on the settings menu: <https://github.com/settings/tokens>. Create a personal access token with the
    correct scope `(user,admin:org)`.  Record this value, but be sure it is in a SECURE location (since access to this
    token confers the power to take any action in github that the machine user is authorized to take.)  In particular,
    do not store it in any github repo, or anywhere that it could potentially leak.

Keep this window open so that you have these values available for step 3, deploying to Heroku.

## Step 3: Deploy your Application on Heroku

You need these windows open:
* the window from Step 1 where you created the values for `OMNIAUTH_PROVIDER_KEY` and `OMNIAUTH_PROVIDER_SECRET` 
* the window from Step 2 where you created the values for `MACHINE_USER_NAME` and `MACHINE_USER_KEY`
* this window (for these instructions)
* a fourth window you will get by shift-clicking the purple  "deploy to heroku button".

So, now, shift-click this pretty purple button: [![Deploy to Heroku](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

You'll be asked for the name of your application.  You'll then be asked for the values of those four environment variables.

Once you've supplied those you should be able to navigate to the application at `https://appname.herokuapp.com`.

Login as the instructor, and then begin setting up the course by choosing an organization, and uploading a course roster.

Information for Developers
==========================

Ruby on Rails
-------------

This application requires:

- Ruby 2.3.0
- Rails 5.0.1
- PostgreSQL

Learn more about [Installing Rails](http://railsapps.github.io/installing-rails.html).

Run the app in development
--------------------------

To run this application in development, you need Postgres running locally, and a postgres user called `course-github-org-tool`.  Create it like this:

```
$ psql -d postgres
psql (9.4.5)
Type "help" for help.

defunkt=# create user "course-github-org-tool" with createdb;
CREATE ROLE
defunkt=# \q
```

Also, copy the file `.env.example` into a new file `.env` (set as ignored in the `.gitignore` file) and set the appropriate values.
* Values for github oauth from, for example <https://github.com/settings/applications/new>
  * The callback url will be `https://<<your-url>>/auth/github/callback`
* Create a utility machine account, and create a personal access token with the correct scope (user,admin:org) here: <https://github.com/settings/tokens>
  * NOTE: If you want to create a new account, but don't have a spare email address, you can use an email tag if you use a `sendmail` or Gmail account
  * For example, if your email is `foobar@gmail.com`, then a unique email could be `foobar+machine-account-test@gmail.com` and all emails to that address would be routed to your `foobar@gmail.com` mailbox.
  * For more information about this neat hack, check [this link](https://www.cs.rutgers.edu/~watrous/plus-signs-in-email-addresses.html) out.

This application utilizes the `dotenv-rails` gem, which automatically loads any variables specified in a file called `.env` in the project root into the environment when running the application.

Once you complete the above, run `bundle install`, `rails db:setup` and `rails db:migrate`, `rails serve`, etc. in the normal fashion.

Documentation and Support
-------------------------

TODO

Issues
-------------

TODO

Similar Projects
----------------

TODO

Contributing
------------

TODO

Development
-----------

Helpful tool for roster upload: <https://github.com/pconrad/faker-try-egrades>

Credits
-------

This application was generated with the [rails_apps_composer](https://github.com/RailsApps/rails_apps_composer) gem
provided by the [RailsApps Project](http://railsapps.github.io/).

Rails Composer is supported by developers who purchase our RailsApps tutorials.

License
-------

Copyright © 2017 Nick Brown ([@ncbrown1](https://github.com/ncbrown1)). This source code is licensed under the MIT license found in the [LICENSE](https://github.com/project-anacapa/course-github-org-tool/blob/master/LICENSE) file.
