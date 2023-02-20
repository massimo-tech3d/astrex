defmodule Astrex.Server do
  @moduledoc """
  TODO ELABORA !!!!
  Functions for astronomical coordinates calculations and objects positions
  - coordinates conversions between AR/DEC and ALT/AZ and viceversa
  - ALT/AZ speed
  - RA/DEC positions of Sun, Moon, Planets at a given day/time
  - RA/DEC positions of full NGC/IC database objects
  """

  require Logger
  use GenServer

  # client API

  # def start_link(_state \\ [], _opts \\ []) do
  def start_link(state = %{lat: _lat, long: _long} \\ %{lat: 51.477928, long: 0.0}, _opts \\ []) do
    # GenServer.start_link(__MODULE__, :ok, [name: __MODULE__])
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def get_ll() do
    GenServer.call(__MODULE__, :get_coords)
  end

  def set_ll(ll) do
    GenServer.cast(__MODULE__, {:set_coords, ll})
  end

  # server API

  # def init(:ok) do
  def init(lat_long = %{lat: _lat, long: _long} \\ %{lat: 51.477928, long: 0.0}) do
    # lat_long = %{lat: 51.477928, long: 0.0}  # Greenwich coordinates
    Logger.info("Starting Astrex GenServer")
    {:ok, lat_long}
  end

  @doc """
    No calls are used but callback is mandatory
  """
  def handle_call(:get_coords, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:set_coords, %{lat: lat, long: long}}, _state) do
    {:noreply, %{lat: lat, long: long}}
  end
end
