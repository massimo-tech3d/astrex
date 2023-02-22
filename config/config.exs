# This file is responsible for configuring your application and its
# dependencies.
#
# This configuration file is loaded before any dependency and is restricted to
# this project.
import Config

# Enable the Nerves integration with Mix
# Astrex.Application.start(1, 2)  # arguments not yet used

config :astrex, :default_location, %{lat: 51.477928, long: 0.0}
# config :astrex, :time_source, :real
config :astrex, :time_source, :mock
config :astrex, :mock_time, ~N[2023-01-01 18:00:15.922068]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
