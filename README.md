# Dreamwalk Padrino API Extension

Handles API request validation and authorisation.

## Installation

Add this line to your application's Gemfile (changing the version to the one you want):

    gem 'dreamwalk_padrino_api', :git => 'git@git.dreamwalk.co:root/gem-dw_padrino_api.git', :tag => '2.0.0', :require => false

And then execute:

    $ bundle


## Usage

Create the database tables for API requests and tokens; see `examples/migration.rb` for a sample Sequel migration file.

Add the following lines to your application class(es) in `[app_name]/app.rb`:

  require 'dreamwalk_padrino_api'
  register DreamWalk::Padrino::Api

That will automatically enable request validation, forcing request headers to be properly set. Sometimes, it is convenient to disable this feature to simplify testing on tools like Postman. To do that, add this line to `[app_name]/app.rb`:

    disable :api_authentication


## Caveats

If using tokens, if your User model uses the `sequel-paranoid` plugin, you'll need to explicitly tell User deletes to cascade to the tokens - otherwise, tokens belonging to deactivated users will still be considered valid. This can be accomplished by adding these lines to your User model:

    one_to_many :api_user_tokens
    plugin(:association_dependencies, :api_user_tokens => :delete)

When not using `sequel-paranoid`, deletes cascade automatically thanks to foreign key constraints on the api_user_tokens table.