defmodule Astrex.Common do
  @moduledoc """
    Common utilities to facilitate the astronomical calculations
    - unit conversions: hours, degrees, angles
    - normalizations within 360°, 2PI, 24 hours
    - conversion from hour:minutes:seconds to hours
  """

  @pi_x_2 Math.pi() * 2

  @doc """
    returns the current time:
    - system time if production
    - mock time is testing
  """
  def ndt_now() do
    time_source = Application.get_env(:astrex, :time_source)

    case time_source do
      :real -> NaiveDateTime.utc_now()
      :mock -> Application.get_env(:astrex, :mock_time)
      _ -> NaiveDateTime.utc_now()
    end
  end

  @doc """
    formats an hour from hours to a string "hh:mm:ss"
  """
  def hours2hms(h) do
    hours = trunc(h)
    m = abs(h - trunc(h))
    min = trunc(m * 60)
    sec = trunc((m * 60 - trunc(m * 60)) * 60)
    "#{hours |> pad_i(2)}:#{min |> pad_i(2)}:#{sec |> pad_i(2)}"
  end

  @doc """
    formats an angle from degrees to a string "dd:mm:ss"
  """
  def deg2dms(d) do
    deg = trunc(d)
    m = abs(d - trunc(d))
    min = trunc(m * 60)
    sec = trunc((m * 60 - trunc(m * 60)) * 60)
    "#{deg |> pad_i(2)}:#{min |> pad_i(2)}:#{sec |> pad_i(2)}"
  end

  @doc """
    Converts all values of a map from degrees to radians.
  """
  def map2rad(map = %{}) do
    Enum.reduce(map, %{}, fn {k, v}, acc -> Map.put(acc, k, Math.deg2rad(v)) end)
    # Map.new(map, fn {k, v} -> {k, Math.deg2rad(v)} end)
  end

  @doc """
    Converts all values of a map from radians to degrees.
  """
  def map2deg(map = %{}) do
    Enum.reduce(map, %{}, fn {k, v}, acc -> Map.put(acc, k, Math.rad2deg(v)) end)
    # Map.new(map, fn {k, v} -> {k, Math.rad2deg(v)} end)
  end

  @doc """
    converts an angle expressed in radians to an angle expressed in hours
  """
  @spec rad2hours(float) :: float
  def rad2hours(rad) do
    rad * 3.8197186342054880584532103209403
  end

  @doc """
    converts an angle expressed in hours to an angle expressed in radians
  """
  @spec hours2rad(float) :: float
  def hours2rad(hours) do
    hours * 0.26179938779914943653855361527329
  end

  @doc """
    converts an angle expressed in hours to an angle expressed in degrees
  """
  @spec hours2deg(float) :: float
  def hours2deg(hours) do
    hours * 15
  end

  @doc """
    converts an angle expressed in degrees to an angle expressed in hours
  """
  @spec deg2hours(float) :: float
  def deg2hours(deg) do
    deg / 15.0
  end

  @doc """
    Converts a "hh:mm:ss" string to hours
    receives a binary string
    returns HOURS in float format
  """
  @spec hms2hours(binary) :: float
  def hms2hours(angle) do
    [hour, minute, seconds] = String.split(angle, ":")
    {h, _} = Integer.parse(hour)
    {m, _} = Integer.parse(minute)
    {s, _} = Float.parse(seconds)

    if h < 0 do
      -(abs(h) + m / 60 + s / 3600)
    else
      h + m / 60 + s / 3600
    end
  end

  @doc """
    Converts a "dd:mm:ss" string to degrees
    Receives the angle in d° m' s" as a binary string
    Returns the angle in DEGREES (float)
  """
  @spec dms2deg(binary) :: float
  def dms2deg(angle) do
    [deg, min, sec] = String.split(angle, ":")
    {d, _} = Integer.parse(deg)
    {m, _} = Integer.parse(min)
    {s, _} = Float.parse(sec)

    if d < 0 do
      -(abs(d) + m / 60 + s / 3600)
    else
      d + m / 60 + s / 3600
    end
  end

  @doc """
    Normalizes an angle into the range 0°-360°
    Receives the angle in DEGREES
    Returns the normalized angle in DEGREES
  """
  @spec norm_360(float) :: float
  def norm_360(a) when a >= 360 do
    norm_360(a - 360)
  end

  def norm_360(a) when a < 0 do
    norm_360(a + 360)
  end

  def norm_360(a) do
    a
  end

  @doc """
    Normalizes an hour angle into the range 0-24 hours
    Receives the angle in HOURS
    Returns the normalized angle in HOURS
  """
  @spec norm_24h(float) :: float
  def norm_24h(a) when a >= 24 do
    norm_24h(a - 24)
  end

  def norm_24h(a) when a < 0 do
    norm_24h(a + 24)
  end

  def norm_24h(a) do
    a
  end

  @doc """
    Normalizes an angle into the range 0-2 pi
    Receives the angle in RADIANS
    Returns the normalized angle in RADIANS
  """
  @spec norm_2pi(float) :: float
  def norm_2pi(a) when a >= @pi_x_2 do
    norm_2pi(a - @pi_x_2)
  end

  def norm_2pi(a) when a < 0 do
    norm_2pi(a + @pi_x_2)
  end

  def norm_2pi(a) do
    a
  end

  defp pad_i(i, n) do
    i
    |> Integer.to_string()
    |> String.pad_leading(n, "0")
  end
end
