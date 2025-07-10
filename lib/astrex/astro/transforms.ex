defmodule Astrex.Astro.Transforms do
  @moduledoc """
    The module exports functions to convert from different coordinates systems
      AltAzimuth to Equatorial
      Equatorial to AltAzimuth
      Ecliptic to Equatorial
      Equatorial to Ecliptical

    Unless otherwise stated the formulas are implemented according to the Jean Meeus book:
    "Astronomical Algorithms"

    Chapter 13 - Transformation of Coordinates

    The following conventions apply:
      Longitudes East of Greenwich is POSITIVE: 0° to 180°
      Longitudes West of Greenwich is NEGATIVE: 0° to -180°
      Azimuth North is 0°
      Azimuth East is 90°
      Azimuth South is 180°
      Azimuth West is 270°

    All data need to be expressed in radians, not in degrees or hours
  """

  import Math
  alias Astrex.Common, as: C
  alias Astrex.Astro.Dates

  @doc """
    Converts from AltAzimth coordinates to Equatorial Celestial coordinates
             according to algorithms from "Practical Astronomy with your calculator"
             by Peter Duffet and Jonathan Zwart
    Receives: map: Altitude, Azimuth in DEGREES
              map: Latitude, Longitude in DEGREES
              NaiveDateTime

    Returns : map: Right Ascension, Declination in DEGREES

    Note: does NOT take refraction into account
  """
  def az2eq(%{alt: alt, az: az_d}, %{lat: lat, long: long}, dt = %NaiveDateTime{}) do
    lst_h = Dates.local_sidereal_time(long, dt)   # lst in hours
    lst_d = C.hours2deg(lst_h)                    # lst in degrees
    # IO.puts("LST ore #{lst_h} LST° #{lst_d}")

    az_r = az_d |> deg2rad
    alt_r = alt |> deg2rad
    lat_r = lat |> deg2rad

    sind = sin(alt_r)*sin(lat_r)+cos(alt_r)*cos(lat_r)*cos(az_r)
    dec_r = asin(sind)
    dec_d = dec_r |> rad2deg

    ha_r = atan2(-cos(alt_r)*cos(lat_r)*sin(az_r), (sin(alt_r)-sin(lat_r)*sind))
    ha_d = ha_r |> rad2deg
    ra_d = (lst_d - ha_d) |> C.norm_360

    %{ra: ra_d, dec: dec_d}  # both in degrees
  end

  @doc """
    Converts from Equatorial Celestial coordinates to AltAzimth coordinates
             according to algorithms from "Practical Astronomy with your calculator"
             by Peter Duffet and Jonathan Zwart
    Receives: map: Right Ascension and Declination in DEGREES
              map: Latitude, Longitude in DEGREES
              NaiveDateTime
    Returns : map: Altitude and Azimuth in DEGREES

  ## Examples:
      iex> site = %{lat: 45.52, long: 9.21}
      iex> obj  = %{ra: 97.3792, dec: 23.1486}
      iex> date = ~N[2025-07-09 17:22:00]
      iex> Astrex.Astro.Transforms.eq2az(obj, site, date)
      %{alt: 9.55870765323566, az: 293.42107862051745}

      Note: the example from the book returns az: 68.037813189937 because the azimuth convention
            is 0° South. We use 180° for south.
  """
  def eq2az(%{ra: ra, dec: decl}, %{lat: lat, long: long}, dt = %NaiveDateTime{}) do
    # degrees
    lst_h = Dates.local_sidereal_time(long, dt)
    lha_h = (lst_h - ra/15)  # lha in hours
    lha_d = lha_h |> C.hours2deg |> C.norm_360          # lha in degrees

    decl_r = decl |> deg2rad
    lat_r = lat |> deg2rad
    lha_r = lha_d |> deg2rad

    alt_r = asin(sin(decl_r) * sin(lat_r) + cos(decl_r) * cos(lat_r)*cos(lha_r))
    az_r  = atan2(-cos(decl_r) * cos(lat_r) * sin(lha_r), sin(decl_r) - sin(lat_r) * sin(alt_r))

    alt = alt_r |> rad2deg
    az = az_r |> C.norm_2pi |> rad2deg
    # tutto OK

    %{alt: alt, az: az}
  end

  @doc """
    Converts ecliptical latitude and logitude to equatorial AR / DEC at a given time

    Opposite to eq2ecl, there are no reliable test numbers available
    Therefore this function can only be tested via round trip together with eq2ecl

  ## Examples
      iex> test = %{dec: 25.989, ra: 277.892}  # or whatever coordinates
      iex> date = Astrex.Common.ndt_now()
      iex> Astrex.Astro.Transforms.eq2ecl(test, date) |> Astrex.Astro.Transforms.ecl2eq(date)
      %{dec: 25.989000000000008, ra: 277.89199999999994}

      PASSES with float operations approximation
  """
  def ecl2eq(%{longitude: lambda, latitude: beta}, dt = %NaiveDateTime{}) do
    e = ecliptic_obliquity(dt)  # in degrees

    lambda_r = lambda |> deg2rad
    beta_r = beta |> deg2rad
    e_r = e |> deg2rad

    ar = atan2(sin(lambda_r) * cos(e_r) - tan(beta_r) * sin(e_r), cos(lambda_r)) |> rad2deg |> C.norm_360()
    decl = asin(sin(beta_r) * cos(e_r) + cos(beta_r) * sin(e_r) * sin(lambda_r)) |> rad2deg
    # degrees
    %{ra: ar, dec: decl}
  end

  @doc """
    Converts equatorial AR / DEC to ecliptical latitude and logitude at a given time

    Receives:
    RA/DEC expressed in DEGREES
    Returns:
    Longitude/Latitude (ecliptical) expressed in DEGREES

  ## Examples
      iex> date = ~N[1987-04-10 00:00:00]
      iex> obj  = %{ra: 116.328942, dec: 28.026183}
      iex> Astrex.Astro.Transforms.eq2ecl(obj, date)
      %{longitude: 113.215630, latitude: 6.68417}  # in degrees

      PASSES with float operations approximation
  """
  def eq2ecl(%{ra: ra, dec: dec}, dt = %NaiveDateTime{}) do
    e = ecliptic_obliquity(dt)  # in degrees

    ra_r  = ra  |> deg2rad
    dec_r = dec |> deg2rad
    e_r   = e   |> deg2rad

    lambda = atan2(sin(ra_r) * cos(e_r) + tan(dec_r) * sin(e_r), cos(ra_r)) |> rad2deg |> C.norm_360()
    beta = asin(sin(dec_r) * cos(e_r) - cos(dec_r) * sin(e_r) * sin(ra_r)) |> rad2deg |> C.norm_360()

    %{longitude: lambda, latitude: beta}
  end

  # ecliptic obliquitity not affected by nutation/aberration
  # result in DEGREES
  defp ecliptic_obliquity(dt = %NaiveDateTime{}) do
    t = Dates.julian_century(dt)
    t2 = t * t
    t3 = t * t2
    # DEGREES
    23.4392912 - 0.012726389 * t - 0.000000167 * t2 + 0.000000503 * t3
  end
end
