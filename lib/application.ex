defmodule Astrex.Application do
  # https://elixirforum.com/t/making-a-library-with-supervisor-genservers-cant-decide-whats-more-convenient-to-use/50325
  use Application

  @impl true
  def start(_type \\ [], _args \\ []) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options

    location = Application.get_env(:astrex, :default_location)

    opts = [strategy: :one_for_one, name: Astrex.Supervisor]

    children = [
      # Children for all targets
      # Starts a worker by calling: Firmware.Worker.start_link(arg)
      # {Astrex.Server, [:ok]}
      {Astrex.Server, location}
    ]

    Supervisor.start_link(children, opts)
  end
end
