Course Github Org Tool
================

This tool is a first attempt at a MVP for allowing students to self-enroll in a GitHub Organization associated with a course, provided:

* Their school email address (e.g. 'cgaucho@umail.ucsb.edu') appears as a verified email address on their GitHub account
* That email is in the course roster for the course (uploaded by the instructor)

It also provides an interface for instructors to view which of their students have or have not enrolled in the GitHub Organization for the course, provided that the students have logged in to the application OR the application knows about the students' GitHub usernames.

Deploying on Heroku
===================

To deploy this app on Heroku, you will need:

1. A github organization for your course, to which the instructor has owner access.

1. Values for the environment variables OMNIAUTH_PROVIDER_KEY and OMNIAUTH_PROVIDER_SECRET, which come from setting up an
    OAuth application in Github.    These can be associated with a github user, or with a github organization.  Set these
    up here, for example: <https://github.com/settings/applications/new>

1. The userid of a github "machine user" as explained here: 
    <https://developer.github.com/guides/managing-deploy-keys/#machine-users>.   This user is the the user that acts on
    behalf of the application.   One of the first steps in application setup is to give this "machine user" owner access
    to the organization so that it can add students to the organization on behalf of the instructor (this allows us to
    limit the scope of what the application has access to---only a single organization rather than everything the 
    instructor's account could potentially do.)
    
    To set one of these up, simply log out of github, and create a brand new github user.  When prompted for an email,
    you'll find that if you use an email that is already associated with a github account, you'll get an error.  To
    get around this, add a tag to your email, as in this example: instead of `jsmith@gmail.com`, use `jsmith+github-mu@gmail.com` or instead of `pconrad@cs.ucsb.edu`, use `pconrad+github-tool@cs.ucsb.edu`.
   
1.  A personal access token for the machine user.  While logged in to github "as the machine user", access this 
    item on the settings menu: <https://github.com/settings/tokens>. Create a personal access token with the 
    correct scope `(user,admin:org)`.  Record this value, but be sure it is in a SECURE location (since access to this
    token confers the power to take any action in github that the machine user is authorized to take.)  In particular,
    do not store it in any github repo, or anywhere that it could potentially leak.

With these four pieces of information, you are ready to deploy to Heroku.

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

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

Credits
-------

This application was generated with the [rails_apps_composer](https://github.com/RailsApps/rails_apps_composer) gem
provided by the [RailsApps Project](http://railsapps.github.io/).

Rails Composer is supported by developers who purchase our RailsApps tutorials.

License
-------

TODO
