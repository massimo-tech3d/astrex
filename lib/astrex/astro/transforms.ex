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
            Follows the Azimuth convention of South @ 180° (performs the necessary
            conversion to comply to Meeus algo which is South @ 0°)
    Receives: map: Altitude, Azimuth in DEGREES
              map: Latitude, Longitude in DEGREES
              NaiveDateTime

    Returns : map: Right Ascension, Declination in DEGREES

    Note: does NOT take refraction into account
  """
  def az2eq(%{alt: alt, az: az}, %{lat: lat, long: long}, dt = %NaiveDateTime{}) do
    # hours
    lst = Dates.local_sidereal_time(long, dt)
    # degrees
    lst = C.hours2deg(lst)
    # degrees
    az = az - 180

    # degrees
    ha = datan2(dsin(az), dcos(az) * dsin(lat) + dtan(alt) * dcos(lat))
    # degrees
    ra = (lst - ha) |> C.norm_360()
    # degrees
    dec = dasin(dsin(lat) * dsin(alt) - dcos(lat) * dcos(alt) * dcos(az))

    %{ra: ra, dec: dec}
  end

  @doc """
    Converts from Equatorial Celestial coordinates to AltAzimth coordinates
             according to Jean Meeus Algorithm
             Follows the Azimuth convention of South @ 180° (performs the necessary
             conversion to comply to Meeus algo which is South @ 0°)
    Receives: map: Right Ascension and Declination in DEGREES
              map: Latitude, Longitude in DEGREES
              NaiveDateTime
    Returns : map: Altitude and Azimuth in DEGREES

    (see Meeus Astronomical Algorithms page 95 example 13.b)
  ## Examples:
      iex> site = %{lat: 38.921, long: 77.065}
      iex> obj  = %{ra: 347.316, dec: -6.719}
      iex> date = ~N[1987-04-10 19:21:00]
      iex> Astrex.Astro.Transforms.eq2az(obj, site, date)
      %{alt: 15.122211840841763, az: 248.037813189937}

      Note: the example from the book returns az: 68.037813189937 because the azimuth convention
            is 0° South. We use 180° for south.
  """
  def eq2az(%{ra: ra, dec: decl}, %{lat: lat, long: long}, dt = %NaiveDateTime{}) do
    # degrees
    lha = (Dates.local_sidereal_time(long, dt) |> C.hours2deg()) - ra
    # degrees
    az = (datan2(dsin(lha), dcos(lha) * dsin(lat) - dtan(decl) * dcos(lat)) + 180) |> C.norm_360()
    # degrees
    alt = dasin(dsin(lat) * dsin(decl) + dcos(lat) * dcos(decl) * dcos(lha))

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
    e = ecliptic_obliquity(dt)

    ar = datan2(dsin(lambda) * dcos(e) - dtan(beta) * dsin(e), dcos(lambda)) |> C.norm_360()
    decl = dasin(dsin(beta) * dcos(e) + dcos(beta) * dsin(e) * dsin(lambda))
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
      %{lambda: 113.215630, beta: 6.68417}  # in degrees

      PASSES with float operations approximation
  """
  def eq2ecl(%{ra: ra, dec: dec}, dt = %NaiveDateTime{}) do
    e = ecliptic_obliquity(dt)

    lambda =
      datan2(dsin(ra) * dcos(e) + dtan(dec) * dsin(e), dcos(ra)) |> Astrex.Common.norm_360()

    beta = dasin(dsin(dec) * dcos(e) - dcos(dec) * dsin(e) * dsin(ra)) |> Astrex.Common.norm_360()
    %{longitude: lambda, latitude: beta}
  end

  # ecliptic obliquitity not affected by nutation/aberration
  # result in DEGREES
  defp ecliptic_obliquity(dt = %NaiveDateTime{}) do
    t = Dates.julian_century(dt)
    # DEGREES
    23.4392911 - 0.0130125 * t
  end

  defp dsin(a) do
    sin(a |> deg2rad)
  end

  defp dcos(a) do
    cos(a |> deg2rad)
  end

  defp dtan(a) do
    tan(a |> deg2rad)
  end

  defp dasin(a) do
    asin(a) |> rad2deg
  end

  defp datan2(a, b) do
    atan2(a, b) |> rad2deg
  end
end
