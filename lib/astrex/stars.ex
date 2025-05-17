defmodule Astrex.Stars do
  alias Astrex.Common, as: C
  require Logger

  @moduledoc """
    This module provides functions to query for Bright stars in a list of 200 up to magnitude 3.1

    The intended usage is retrieving the most appropriate stars to perform a 2/3 stars alignment of a telescope

    The catalog is excerpted from https://in-the-sky.org/data/catalogue.php?cat=Bright+Star and
    limited to one or two stars from each constellation, within the magnitude limits described above

    The available columns are
      0: Magnitude
      1: Constellation
      2: RA               Right Ascension - format hh:mm:ss
      3: Dec              Declination     - format (-)deg:min:secs
      4: Name             Primary name, such as α-CMa
      5: aka              Also known as, such as Sirius

    The following filtering are provided
    - by magnitude (brighter than)
    - by azimuth from a given position - not closer than specified degrees
    - by azimuth from a given position - not farther than specified degrees
    - by altitude from a given position - not closer than specified degrees
    - by altitude from a given position - not farther than specified degrees

    The filters can be combined

    Note: Coordinates of the objects are returned in (+/-)dd:mm:ss and hh:mm:ss (strings)
  """

  defp catalog do
    Application.app_dir(:astrex, "priv/200-brightest-stars.csv")
  end


  @doc """
  finds all bright stars that meet the specifications:
  - maximum magnitude (anything as bright or brigther matches)
  - closer than X degrees from given coordinates (only close stars match)
  - farther than X degrees from given coordinates (only farther stars match)

  accepts 3 arguments:
  - magnitude         - required, integer

  - %{az: ref_az, d_az: delta_az, type_az: "IN"/"OUT"} - optional, map
                      delta_az is the distance plus/minus ref_az defining the search interval
                      type_az, IN/OUT, determines the search IN or OUT the interval

  - %{alt: ref_alt, d_alt: delta_alt, type_alt: "IN"/"OUT"} - optional, map
                      delta_az is the distance plus/minus ref_az defining the search interval
                      type_az, IN/OUT, determines the search IN or OUT the interval

  ## Examples
      iex> Astrex.Server.start_link
      iex> Astrex.Stars.select_stars(0.5, %{az: 90, d_az: 45, type_az: "IN"}, %{alt: 60, d_alt: 30, type_alt: "IN"})
      [
        %{aka: "Capella", alt: 46.471899486382085, ra: "05:16:41", az: 69.23413116540189, const: "Auriga", dec: "45:59:56", id: "α-Aur", mag: "0.1"}
      ]

      one star found matching the requirements at the mock time/mock location

            Astrex.Server.get_ll --> %{lat: 51.477928, long: 0.0}
            Astrex.Common.ndt_now --> ~N[2023-01-01 18:00:15.922068]

      iex> Astrex.Server.start_link
      iex> Astrex.Stars.select_stars(0.5)
      [
        %{aka: "Capella", alt: 46.471899486382085, az: 69.23413116540189, const: "Auriga", dec: "45:59:56", id: "α-Aur", mag: "0.1", ra: "05:16:41"},
        %{aka: "Vega", alt: 28.25618477533259, az: 297.8147144352378, const: "Lyra", dec: "38:46:58", id: "α-Lyr", mag: "0.0", ra: "18:36:56"},
        %{aka: "Rigel", alt: 7.176735179533099, az: 112.89401627493982, const: "Orion", dec: "-08:12:05", id: "β-Ori", mag: "0.3", ra: "05:14:32"},
        %{aka: "Procyon", alt: -4.292759056473423, az: 76.05487291217511, const: "Canis Minor", dec: "05:13:39", id: "α-CMi", mag: "0.4", ra: "07:39:18"},
        %{aka: "Sirius", alt: -13.057787690330622, az: 100.52410739917546, const: "Canis Major", dec: "-16:42:47", id: "α-CMa", mag: "-1.4", ra: "06:45:09"},
        %{aka: "Arcturus", alt: -16.585528504402962, az: 337.6290585758656, const: "Bootes", dec: "19:11:14", id: "α-Boo", mag: "0.2", ra: "14:15:40"},
        %{aka: "Achernar", alt: -19.256179758399565, az: 172.46262860557806, const: "Eridanus", dec: "-57:14:11", id: "α-Eri", mag: "0.5", ra: "01:37:42"},
        %{aka: "Canopus", alt: -36.018291932764726, az: 131.73791696086482, const: "Carina", dec: "-52:41:44", id: "α-Car", mag: "-0.6", ra: "06:23:57"},
        %{aka: "Rigil Kentaurus", alt: -71.68742064459886, az: 228.18421733259387, const: "Centaurus", dec: "-60:50:06", id: "α-Cen", mag: "-0.0", ra: "14:39:40"},
      ]

      all 9 stars brigther than magnitude 0.5 matched the specification and where returned in order of altitude (highest first)
  """
  def select_stars(max_mag, %{az: ref_az, d_az: delta_az, type_az: type_az}, %{alt: ref_alt, d_alt: delta_alt, type_alt: type_alt}) do
    open_csv()
    |> stars_to_map
    |> Stream.map(fn m -> inject_altaz(m) end)
    |> filter_mag(max_mag)
    |> filter_az(ref_az, delta_az, type_az)
    |> filter_alt(ref_alt, delta_alt, type_alt)
    # takes all
    |> Enum.to_list()
  end
  def select_stars(max_mag, %{az: ref_az, d_az: delta_az, type_az: type_az}) do
    open_csv()
    |> stars_to_map
    |> Stream.map(fn m -> inject_altaz(m) end)
    |> filter_mag(max_mag)
    |> filter_az(ref_az, delta_az, type_az)
    # takes all
    |> Enum.to_list()
  end
  def select_stars(max_mag, %{alt: ref_alt, d_alt: delta_alt, type_alt: type_alt}) do
    open_csv()
    |> stars_to_map
    |> Stream.map(fn m -> inject_altaz(m) end)
    |> filter_mag(max_mag)
    |> filter_alt(ref_alt, delta_alt, type_alt)
    # takes all
    |> Enum.to_list()
  end
  # sort stars by altiture. Highest first
  def select_stars(max_mag) do
    open_csv()
    |> stars_to_map
    |> Stream.map(fn m -> inject_altaz(m) end)
    |> filter_mag(max_mag)
    |> Enum.sort(&(&1.alt >= &2.alt)) # sort by altitude
    # takes all
    |> Enum.to_list()
  end

  def select_star_by_name(name) do
    open_csv()
    |> stars_to_map
    |> filter_name(name)
    # takes all
    |> Enum.to_list()
    |> hd
    |> fix_ra_dec
  end

  defp inject_altaz(m) do
    rao = C.hms2hours(m.ra) |> C.hours2deg()
    deco = C.dms2deg(m.dec)
    %{alt: alt, az: az} = Astrex.eq2az(%{ra: rao, dec: deco})
    m = Map.put(m, :az, az)
    m = Map.put(m, :alt, alt)
    m
  end

  # Returns a stream of the catalog file, lines are trimmed and stripped
  defp open_csv() do
    File.stream!(catalog())
    # trims the line
    |> Stream.map(&String.trim(&1))
    # splits line into columns
    |> Stream.map(&String.split(&1, ","))
    |> Stream.filter(fn
      # skips header
      ["Mag" | _] -> false
      [_, _, _, _, _, _] -> true
    end)
  end

  def filter_name(st, name) do
    Stream.filter(st, fn
      %{id: id} ->
        id == name
    end)
  end

  # Filters out all stars that are fainter than the specified magnitude
  defp filter_mag(st, magnitude) do
    Stream.filter(st, fn
      %{mag: mag} ->
        case Float.parse(mag) do
          {m, _} -> m <= magnitude
          :error -> false
        end
    end)
  end

  # Filters out all stars that are farther or closer to the reference azimuth
  defp filter_az(st, ref_az, delta, min_max) do
    Stream.filter(st, fn
      %{ra: ra, dec: dec} ->
        rao = C.hms2hours(ra) |> C.hours2deg()
        deco = C.dms2deg(dec)
        %{alt: _alt, az: az} = Astrex.eq2az(%{ra: rao, dec: deco})
        in_int = in_az_interval(az, ref_az, delta)
        if min_max == "IN" do
          in_int
        else
          !in_int
        end
    end)
  end

  # Filters out all stars that are farther or closer to the reference altitude
  defp filter_alt(st, ref_alt, delta, min_max) do
    min_alt = ref_alt - delta
    max_alt = ref_alt + delta
    Stream.filter(st, fn
      %{ra: ra, dec: dec} ->
        rao = C.hms2hours(ra) |> C.hours2deg()
        deco = C.dms2deg(dec)
        %{alt: alt, az: _az} = Astrex.eq2az(%{ra: rao, dec: deco})
        in_int = alt >= min_alt and alt <= max_alt
        if min_max == "IN" do
          in_int
        else
          !in_int
        end
    end)
  end

  defp stars_to_map(l) do
    Enum.map(l, fn s -> star_to_map(s) end)
  end

  defp star_to_map([magnitude, constellation, ra, dec, id, aka]) do
    %{
      id: id, mag: magnitude, const: constellation, ra: ra, dec: dec, aka: aka,
    }
  end
  defp star_to_map([]) do
    %{}
  end

  defp in_az_interval(az, ref_az, delta) do
    min_az = C.norm_360(ref_az - delta)
    max_az = C.norm_360(ref_az + delta)
    if min_az < max_az do
      calc_in_az_interval(az, min_az, max_az)
    else   # interval across 0/360° -- checks reverted
      !calc_in_az_interval(az, max_az, min_az)
    end
  end

  defp calc_in_az_interval(az, min_az, max_az) do
    az >= min_az and az <= max_az
  end

  defp fix_ra_dec(star) do
    %{star | ra: C.hms2hours(star.ra), dec: C.dms2deg(star.dec)}
  end
end
