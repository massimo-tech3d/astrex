defmodule Astrex.Application do
  # https://elixirforum.com/t/making-a-library-with-supervisor-genservers-cant-decide-whats-more-convenient-to-use/50325
  use Application

  @impl true
  def start(_type \\ [], _args \\ []) do
    location = Application.get_env(:astrex, :default_location)

    opts = [strategy: :one_for_one, name: Astrex.Supervisor]

    children = [
      {Astrex.Server, location}
    ]

    Supervisor.start_link(children, opts)
  end
end
