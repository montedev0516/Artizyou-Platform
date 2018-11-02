# Forest Rails Liana [![Build Status](https://travis-ci.org/ForestAdmin/forest-rails.svg?branch=master)](https://travis-ci.org/ForestAdmin/forest-rails)

The official Rails liana for [Forest Admin](https://www.forestadmin.com).
Forest is a modern admin interface (see the [live demo](https://app.forestadmin.com/23065?livedemo)) that works on all major web frameworks.
forest_liana is a Rails Admin Gem that makes Forest admin work on any Rails application (Rails >= 4.0). 

## Installation

Visit [Forest's website](https://www.forestadmin.com), enter your email and click "Get started".  
You will then follow a 4-step process:

1. Choose your stack (Rails)
2. Install Forest Liana
  ```ruby
  ## Add to your application's Gemfile
  gem 'forest_liana'

  ## Bundle it
  bundle install

  ## Install it with the provided environment secret
  rails g forest_liana:install FOREST-ENV-SECRET
  ```
3. Get your app running, provide your application URL and check if you have successfully installed Forest Liana on your app.  
4. Choose your credentials, log into https://app.forestadmin.com and start customizing your admin interface! 🎉

## How it works

Installing `forest_liana` into your app will automatically generate an admin REST API for your app.  
This API allows the Forest admin UI to communicate with your app and operate on your data.  
Note that data from your app will never reach Forest's servers. Only your UI configuration is saved.  
As this gem is open-source, you're free to extend the admin REST API for any operation specific to your app.  

## Documentation

Complete documentation is available at https://docs.forestadmin.com/rails

## How to contribute

This liana is officially maintained by Forest.  
We're always happy to get contributions for other fellow lumberjacks.  
All contributions will be reviewed by Forest's team before being merged into master.

Here is the contribution workflow:

1. **Fork** the repo on GitHub
2. **Clone** the project to your own machine
3. **Commit** changes to your own branch
4. **Push** your work back up to your fork
5. Submit a **Pull request** so that we can review your changes

Please ensure that the **tests** are passing before submitting any pull request:
```
$ RAILS_ENV=test bundle exec rake --trace db:migrate test
```

## Licence

[GPL v3](https://github.com/ForestAdmin/forest-rails/blob/master/LICENSE)
