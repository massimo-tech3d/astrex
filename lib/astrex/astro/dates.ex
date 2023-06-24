defmodule Astrex.Astro.Dates do
  # Sidereal Time at Greenwhich
  # Meeus chapter 12

  @moduledoc """
    This module provides high accuracy functions to calculate key date values
    for further astronomical calculations.
    - Greenwhich Mean Standard Time
    - Local Sidereal Time
    - Julian Day with decimal precision (if decimals not required, Timex.to_julian can be used instead)
    - Julian Century

    Algorithms and coefficients to calculate GMST and LST have been taken
    form the following articles:
      https://astronomy.stackexchange.com/questions/24859/local-sidereal-time
      https://squarewidget.com/astronomical-calculations-sidereal-time/

  """
  alias Astrex.Common, as: C

  @doc """
    Greenwitch Mean Sidereal Time for a given day/time

    site where to confirm the calculation for arbitrary location and current time
    https://astro.subhashbose.com/siderealtime/?longitude=9.15
  """
  @spec gmst(%NaiveDateTime{}) :: float()
  def gmst(dt = %NaiveDateTime{}) do
    hour = dt.hour
    minute = dt.minute
    {micros, _} = dt.microsecond
    seconds = dt.second + micros / Math.pow(10, 6)

    dt = %NaiveDateTime{dt | hour: 0, minute: 0, second: 0, microsecond: {0, 0}}
    t = julian_century(dt)

    t2 = t * t
    t3 = t2 * t
    sid = 100.46061837 + 36000.770053608 * t + 0.000387933 * t2 - t3 / 38_710_000

    (sid + ((hour |> C.hours2deg()) + minute * 0.25 + seconds * 0.0041666666666666666666666666666667) * 1.00273790935)
    |> C.deg2hours()
    |> C.norm_24h()
  end

  @doc """
    Local Sidereal Time for a given day/time
    receives longitude in DEGREES and date and time as NaiveDateTime struct
    returns sidereal time expressed in HOURS

    Conventions:
    Longitude is negative east of Greenwich

    The following example are time dependent and will return the shown results only in testing environment

    ## Examples
        iex> Astrex.Astro.Dates.local_sidereal_time(9.15, Astrex.Common.ndt_now()) |> Astrex.Common.hours2hms
        "00:08:11"
  """
  @spec local_sidereal_time(float(), %NaiveDateTime{}) :: float()
  def local_sidereal_time(long, dt = %NaiveDateTime{}) do
    gmst = gmst(dt)
    (gmst - (long |> C.deg2hours())) |> C.norm_24h()
  end

  @doc """
    returns julian day for the given date/time.

    reference: calculations according to Jean Meeus "Astronomical Algorithms"
               chapter 7 - Julian Day

    receives a NaiveDateTime struct
    returns a float day.decimals

    if decimals are not necessary this can be
    easily replaced by the function:  Timex.to_julian/1
  """
  @spec julian_day(%NaiveDateTime{}) :: float()
  def julian_day(day = %NaiveDateTime{}) do
    {y, m} =
      if day.month > 2 do
        {day.year, day.month}
      else
        {day.year - 1, day.month + 12}
      end

    d = day.day + daydecimals(day.hour, day.minute, day.second)
    aa = trunc(y / 100)
    bb = 2 - aa + trunc(aa / 4)

    trunc(365.25 * (y + 4716)) + trunc(30.6001 * (m + 1)) + d + bb - 1524.5
  end

  @doc """
    returns the julian centuries from 1.1.2000
  """
  @spec julian_century(%NaiveDateTime{}) :: float()
  def julian_century(day = %NaiveDateTime{}) do
    (julian_day(day) - 2_451_545) / 36525
  end

  @doc """
    returns the number of the specified date from 31.12.2000

    reference: calculations according to Jean Meeus "Astronomical Algorithms"
               chapter 7 - Julian Day
  """
  @spec day_number(%NaiveDateTime{}) :: float()
  def day_number(day = %NaiveDateTime{}) do
    d = day.day
    m = day.month
    y = day.year
    mins = day.minute
    h = day.hour + mins / 60

    367 * y - Kernel.floor(7 * (y + Kernel.floor((m + 9) / 12)) / 4) + Kernel.floor(275 * m / 9) +
      d - 730_531.5 + h / 24
  end

  defp daydecimals(h, m, s) do
    h / 24 + m / 1140 + s / 86400
  end
end
