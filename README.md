# Eiger

Eiger is a [DSL](http://en.wikipedia.org/wiki/Domain-specific_language) for
easy route creation for Rack applications in Ruby with minimal effort. It is inspired by [Sinatra](http://github.com/sinatra/sinatra) and [Rails](http://github.com/rails/rails) routing engines. 

It supports routes with parameters, namespaces and resource routes (set of [CRUD](http://en.wikipedia.org/wiki/Create,_read,_update_and_delete) routes):

```ruby
# config.ru

require 'eiger'
require './app.rb'
run Eiger::Base
```
```ruby
# app.rb

# simple route
get '/' do
  'Hello world!'
end

# route with named parameter
get '/:name' do
  "Hello #{params[:name]}!"
end

# route with wildcard parameter
get '/foo/*' do
  "This is wildcard route with #{params[:splat].inspect}"
end

# namespaced route
namespace :foo do
  get '/bar' do
   "Foo Bar"
  end
end

# resource route
route 'resource_path', 'resource_controller_name'  
```

Install the gem:

```ruby
# Gemfile
gem 'eiger', github: "garek/eiger"
```

And run with:

```shell
rackup myapp.rb
```

View at: http://localhost:9292


## Table of Contents

* [Eiger](#eiger)
* [Instalation](#instalation)
* [Routes](#routes)
    * [Named parameters](#named-parameters)
    * [Wildcard parameters](#wildcard-parameters)
    * [Namespaces](#namespaces)
    * [Resource routes](#resource-routes)
* [Controllers](#controllers)
* [Example application](#example-application)

## Instalation
If you want to run your Rack application with Eiger, using
[Bundler](http://gembundler.com/) is the recommended way.

In your `Gemfile` add Eiger and Rack gem:

```ruby
# Gemfile
gem 'rack'
gem 'eiger', :github => "garek/eiger"
```


Now you can run your app like this:

```shell
bundle install
rackup app.rb
```

## Routes

In Sinatra, a route is an HTTP method paired with a URL-matching pattern.
Each route is associated with a block:

```ruby
get '/foo' do
  .. show something ..
end

post '/foo' do
  .. create something ..
end

put '/foo' do
  .. replace something ..
end

patch '/foo' do
  .. modify something ..
end

delete '/foo' do
  .. destroy something ..
end

```

Routes are matched in the order they are defined. The first route that
matches the request is invoked.

## Parameters
Route patterns may include named parameters, accessible via the
`params` hash:

```ruby
get '/hello/:name' do
  # matches "GET /hello/foo" and "GET /hello/bar"
  # params['name'] is 'foo' or 'bar'
  "Hello #{params['name']}!"
end
```

## Wildcard parameters
Route patterns may also include splat (or wildcard) parameters, accessible
via the `params['splat']` array:

```ruby
get '/say/*/to/*' do
  # matches /say/hello/to/world
  params['splat'] # => ["hello", "world"]
end

```

Routes may also utilize query parameters:

```ruby
get '/posts' do
  # matches "GET /posts?title=foo&author=bar"
  title = params['title']
  author = params['author']
  # uses title and author variables; query is optional to the /posts route
end
```

