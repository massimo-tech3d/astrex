defmodule Astrex do
  import Math
  alias Astrex.Common, as: C
  alias Astrex.Types, as: T
  alias Astrex.Astro.Transforms, as: Tr

  @moduledoc """
  ## Introduction

    Provides functions that perform astronomical calculations of various kinds.

    - az2eq          converts from horizontal to equatorial coordinates
    - eq2az          converts from equatorial to horizontal coordinates
    - where_is       returns the equatorial coordinates of the specified planet or the moon
    - geomag         returns the magnetic declination for the current location

    All these functions are location dependent (latitude and longitude) and generally are also time
    dependent.

    The Astrex library provides a genserver to host local coordinates, which is responsibility of the
    application to start, supervise and initialize with the local coordinates.

    All the functions from the main Astrex module will retrieve the local coordinates from the server
    and use the system time. This is handy for usage by applications that are geographically specific
    and work in real time, i.e. for telescope control.

    However, all the functions cab be accessed directly from the respective modules by specifying the
    desired coordinate and timestamp.

    Bonus
    - sidereal_speeds, a function to calculate the altitude and azimuth sidereal speeds for a sky point at
      any given altitude/azimuth (only available for current system time and current genserver location)
      Two calculation methods are provided. Both return consistent results, with some small difference which
      does not affect the telescope driving speeds, when used with typical gear ratios.

  ## Conventions

    The following conventions apply throughout the whole library (unless otherwise indicated):
    - Longitudes East of Greenwich is POSITIVE: 0° to -180°
    - Longitudes West of Greenwich is NEGATIVE: 0° to 180°
    - Azimuth North is 0°
    - Azimuth East is 90°
    - Azimuth South is 180°
    - Azimuth West is 270°

  ## Units
    All data need to be expressed in degrees, not in deegrees:minutes:seconds nor in radians

  ## References
    The source of the algorithms is indicated in the docs of each function.
  """

  @mu 7.272e-5  # sidereal rate = earth rotation rate = 7.272 * 10^-5 rad/s

  @doc """
    Converts from AltAzimth coordinates to Equatorial Celestial coordinates

    Does not compensate for the refraction effect. If needed, the compensation can be
    applied to the coords argument before calling this function.

    See Astrex.Astro.Refraction module.
  """
  @spec az2eq(T.altazimuth()) :: T.equatorial()
  def az2eq(coords = %{alt: _alt, az: _az}) do
    site = Astrex.Server.get_ll()

    coords
    |> Tr.az2eq(site, C.ndt_now())
  end

  @doc """
    Converts from Equatorial Celestial coordinates to AltAzimth coordinates

    Does not compensate for the refraction effect. If needed, the compensation can be
    applied to the results of this function.

    See Astrex.Astro.Refraction module.
  """
  @spec eq2az(T.equatorial()) :: T.altazimuth()
  def eq2az(coords = %{ra: _ra, dec: _dec}) do
    site = Astrex.Server.get_ll()

    coords
    |> Tr.eq2az(site, C.ndt_now())
  end

  @doc """
    Returns the current equatorial coordinates of the Moon or planets (including Pluto).
  """
  @spec where_is(T.solar_system()) :: T.equatorial()
  def where_is(ss_object) do
    Astrex.Astro.SolarSystem.where_is(ss_object, C.ndt_now())
  end

  @doc """
    Calculates the magnetic deviation from true north, given the local site coordinates
    (latitude, longitude) and optionally the height above see level. The height is expressed
    in Km and defaults to zero.

    Returns a tuple with the following values, in this order:
      - magnetic declination
      - magnetic inclination
      - total magnetic field intensity
      - epoch of the current datafile

    The magnetic declination value shoud be added to a magnetic compass reading to get the real
    orientation (true north) of the device.
  """
  @spec mag_declination(number) :: {float(), float(), float(), binary()}
  def mag_declination(altitude \\ 0) do
    site = Astrex.Server.get_ll()
    Astrex.Astro.GeoMag.mag_declination(site, altitude)
  end

  @doc """
    Calculates the sidereal speed, in degrees per second, for any given point
    from it's altitude and azimuth coordinates
    Source:
        "A Mathematical Description of the Control System for the William Herschel
        Telescope" R.A.Laing, Royal Greenwich Observatory" pages 2/3

    ## Examples
      iex> Astrex.sidereal_speeds(%{alt: 45, az: 10})
      {4.5061593459496844e-4, 7.042059181503614e-4}
  """
  @spec sidereal_speeds(T.altazimuth()) :: {float, float}
  def sidereal_speeds(coords = %{alt: _alt, az: _az}) do
    coords = coords |> C.map2rad()
    %{lat: lat, long: _long} = Astrex.Server.get_ll() |> C.map2rad()

    # z = zenith distance = 90 - alt
    z = Math.pi() / 2 - coords.alt
    cosLat = Math.cos(lat)
    sinLat = Math.sin(lat)
    cosAz = Math.cos(coords.az)
    sinAz = Math.sin(coords.az)
    cosZ = Math.cos(z)
    sinZ = Math.sin(z)

    # -zRate
    altRate = (sinAz * cosLat * @mu) |> rad2deg
    azRate = (@mu * (sinLat * sinZ - cosLat * cosZ * cosAz) / sinZ) |> rad2deg

    {altRate, azRate}
  end

  @spec sidereal_speeds(T.equatorial()) :: {float, float}
  def sidereal_speeds(coords = %{ra: _ra, dec: _dec}) do
    sidereal_speeds(eq2az(coords))
  end

  # Astrex.Astro.sidereal_speeds2(Astrex.Astro.az2eq(%{alt: 45, az: 10}), 1)
  # calculations for secs seconds in future
  @doc """
    Alternative method to calculate the sidereal speed starting from equatorial coordinates
    1) calculates the AltAz coordinates for current time
    2) calculates the AltAz coordinates for current time + one second
    3) calculates the difference, which are the speeds in degrees per second

    The results are very close to the sidereal speeds calculated with the mathematical method
    the difference is not enough to impact on motors rotation Hz

    ## Examples
      iex> Astrex.sidereal_speeds2(%{alt: 45, az: 10}, 1)
      {4.5187822290415625e-4, 7.061364708533802e-4}
  """
  @spec sidereal_speeds2(T.equatorial(), integer()) :: {float, float}
  def sidereal_speeds2(coords = %{ra: _ra, dec: _dec}, secs) do
    site = Astrex.Server.get_ll()
    now = C.ndt_now()
    next = %NaiveDateTime{now | second: now.second + secs}

    immediate = coords |> Tr.eq2az(site, now)
    next = coords |> Tr.eq2az(site, next)

    {next.alt - immediate.alt, next.az - immediate.az}
  end

  @spec sidereal_speeds2(T.altazimuth(), integer()) :: {float, float}
  def sidereal_speeds2(coords = %{alt: _alt, az: _az}, secs) do
    sidereal_speeds2(az2eq(coords), secs)
  end
end
