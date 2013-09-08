# Vandrake [![Build Status](https://travis-ci.org/motns/vandrake.png)](https://travis-ci.org/motns/vandrake) [![Code Climate](https://codeclimate.com/github/motns/vandrake.png)](https://codeclimate.com/github/motns/vandrake) [![Dependency Status](https://gemnasium.com/motns/vandrake.png)](https://gemnasium.com/motns/vandrake) [![Coverage Status](https://coveralls.io/repos/motns/vandrake/badge.png?branch=master)](https://coveralls.io/r/motns/vandrake)


## What it is
A data validation framework to be used with data models. You just include Vandrake into your class, and it gives you
methods to construct a validation chain for the model attributes.


### Why?

As of right now, all the popular Ruby ORM/ODM frameworks are based on **ActiveModel::Validations** in
some form or another. While it's an excellent validation framework, I felt that the simplified approach
for reporting validation errors wasn't a good fit for things I was working on.

Instead, I decided to port the custom validation framework from an API project I was working on. It is a battle-tested system,
with more detailed (and machine-parsable) errors, and full introspection support for generating documentation.
Plus, thanks to Ruby, it now has a nice clean DSL slapped on top of it.