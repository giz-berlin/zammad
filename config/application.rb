# Copyright (C) 2012-2021 Zammad Foundation, http://zammad-foundation.org/

require_relative 'boot'

require 'rails/all'
require_relative 'issue_2656_workaround_for_rails_issue_33600'

# DO NOT REMOVE THIS LINE - see issue #2037
Bundler.setup

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Zammad
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    Rails.autoloaders.each do |autoloader|
      autoloader.do_not_eager_load "#{config.root}/lib/core_ext"
      autoloader.collapse          "#{config.root}/lib/omniauth"
      autoloader.inflector.inflect(
        'github_database' => 'GithubDatabase',
        'otrs'            => 'OTRS',
        'db'              => 'DB',
      )
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading

    # the framework and any gems in your application.

    # Custom directories with classes and modules you want to be autoloadable.
    config.add_autoload_paths_to_load_path = false
    config.autoload_paths   += %W[#{config.root}/lib]
    config.eager_load_paths += %W[#{config.root}/lib]

    config.active_job.queue_adapter = :delayed_job

    # Use custom logger to log Thread id next to Process pid
    config.log_formatter = ::Logger::Formatter.new

    # REST api path
    config.api_path = '/api/v1'

    # define cache store
    config.cache_store = :zammad_file_store, Rails.root.join('tmp', "cache_file_store_#{Rails.env}"), { expires_in: 7.days }

    # define websocket session store
    config.websocket_session_store = ENV['REDIS_URL'] ? :redis : :file

    # Rails 6.1 returns false when the enqueuing is aborted.
    config.active_job.return_false_on_aborted_enqueue = true

    # default preferences by permission
    config.preferences_default_by_permission = {
      'ticket.agent' => {
        notification_config: {
          matrix: {
            create:           {
              criteria: {
                owned_by_me:     true,
                owned_by_nobody: true,
                subscribed:      true,
                no:              false,
              },
              channel:  {
                email:  true,
                online: true,
              }
            },
            update:           {
              criteria: {
                owned_by_me:     true,
                owned_by_nobody: true,
                subscribed:      true,
                no:              false,
              },
              channel:  {
                email:  true,
                online: true,
              }
            },
            reminder_reached: {
              criteria: {
                owned_by_me:     true,
                owned_by_nobody: false,
                subscribed:      false,
                no:              false,
              },
              channel:  {
                email:  true,
                online: true,
              }
            },
            escalation:       {
              criteria: {
                owned_by_me:     true,
                owned_by_nobody: false,
                subscribed:      false,
                no:              false,
              },
              channel:  {
                email:  true,
                online: true,
              }
            }
          }
        }
      }
    }
  end
end
