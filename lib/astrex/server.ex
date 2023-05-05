defmodule Astrex.Server do
  @moduledoc """
    Provides a GenServer to hold the local coordinates. This is useful for
    applications that are localized (e.g. telescope control) and makes possible
    to access the functions via the Astrex module, without supplying the local
    coordinates each time.

    Use of the GenServer is by no means mandatory. All the functions can be accessed
    via the Astrex.Astro.* modules.

    If the GenServer is used it is responsibility of the application to start, initialize
    and supervise it
  """

  # TODO DEFINE childspec define start_link with empty [] and %{} as initial state

  use GenServer

  # client API

  # def child_spec(arg) do
  #   %{id: Astrex, start: {Astrex, :start_link, [arg]}}
  # end

  @doc """
    The Genserver is initialized using Greenwich coordinates, unless local coordinates are specified
  """
  def start_link(state \\ %{lat: 51.477928, long: 0.0}, _opts \\ [])
  def start_link(state = %{lat: _lat, long: _long}, _opts) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end
  def start_link(_state, _opts) do
    GenServer.start_link(__MODULE__, %{lat: 51.477928, long: 0.0}, name: __MODULE__)
  end

  def get_ll() do
    GenServer.call(__MODULE__, :get_coords)
  end

  def set_ll(ll) do
    GenServer.cast(__MODULE__, {:set_coords, ll})
  end

  def stop() do
    GenServer.cast(__MODULE__, :stop)
  end

  # server API

  def init(lat_long = %{lat: _lat, long: _long} \\ %{lat: 51.477928, long: 0.0}) do
    {:ok, lat_long}
  end

  def terminate(_, _state) do

  end

  def handle_call(:get_coords, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:set_coords, %{lat: lat, long: long}}, _state) do
    {:noreply, %{lat: lat, long: long}}
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end
end
