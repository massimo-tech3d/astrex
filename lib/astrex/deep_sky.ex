defmodule Astrex.DeepSky do
  alias Astrex.Common

  @moduledoc """
    This module provides functions to query for DeepSky objects recorded in the NGC and IC catalogs

    The catalog is taken from https://github.com/mattiaverga/OpenNGC (License CC-BY-4.0) and saved
    locally in priv directory

    Some columns have been dropped for space sake. The available columns are
      0: Name             IC or NGC index
      1: Type             G: Galaxy, Neb: Nebula, OCl: Open Cluster, GCl: Globular Cluster
      2: RA               Right Ascension
      3: Dec              Declination
      4: Const            Constellation
      5: B-Mag            Magnitude
      6: M                Messier index, if existing

    The following searches are provided
    - by direct calatog and id# - will return one item, if found
    - by specifying the maximum magnitude, object type, minimum altitude on the horizon
      and if the search should be limited to Messier objects

    the object types that can be specified, as atoms, are:
    - galaxies:
    - openclusters:
    - globularclusters:
    - nebulas: (all kinds)

    Note: Coordinates of the objects are returned in (+/-)dd:mm:ss and hh:mm:ss (strings)
          this is how they are stored in the catalog and are not converted in order
          not to loose compatibility with new possible catalog releases.
  """

  defp catalog do
    Application.app_dir(:astrex, "priv/NGC.csv")
  end

  @galaxies ["G", "GGroup", "GPair", "GTrpl"]
  @openclusters ["OCl"]
  @globularclusters ["GCl", "CR+N"]
  @nebulas ["PN", "HII", "Neb", "EmN", "RfN", "SNR", "Cl+N"]

  @doc """
  finds the specified object basing on the catalog and the id
  catalog can be :messier, :ngc or :ic

  returns a map for the object or empty map if the requested object
  is below the minimum altitude.

  if the minimum altitude is not specified, it is defaulted to 0°
  i.e. above the horizon

  ## Examples
      iex> Astrex.Server.start_link

      iex> Astrex.DeepSky.find_object(:messier, 1)
      %{ar: "05:34:31.97",
        constellation: "Tau",
        decl: "+22:00:52.1",
        id: "NGC1952",
        kind: "SNR",
        magnitude: "",
        messier: "1"
      }

      iex> Astrex.DeepSky.find_object(:ngc, 1952)
      %{
        ar: "05:34:31.97",
        constellation: "Tau",
        decl: "+22:00:52.1",
        id: "NGC1952",
        kind: "SNR",
        magnitude: "",
        messier: "1"
      }

    NGC 6554 is more than 15° below the horizon
    (on testing fake datetime and location)

      iex> Astrex.DeepSky.find_object(:ngc, 6554, -15)
      %{}

    but it is found with searches down to -25° below the horizon
    (on testing fake datetime and location)

      iex> Astrex.DeepSky.find_object(:ngc, 6554, -25)
      %{
        ar: "18:09:23.98",
        constellation: "Sgr",
        decl: "-18:22:43.3",
        id: "NGC6554",
        kind: "OCl",
        magnitude: "",
        messier: ""
      }
  """
  @spec find_object(binary, integer, integer) :: map
  def find_object(catalog, id, minimum_altitude \\ 0) do
    open_csv()
    |> filter_id(id, catalog)
    |> filter_catalog(catalog)
    |> filter_horizon(minimum_altitude)
    |> Enum.take(1)
    |> head
    |> object_to_map()
  end

  @doc """
  finds all objects that meet the specifications:
  - maximum magnitude (anything as bright or brigther matches)
  - type of object (galaxies, open_clusters, globular_clusters, nebulas)
  - only from messier catalog pass the filter
  - not lower on the horizon than minimum_altitude degrees. Defaults to zero.
    Negative altitudes are accepted to allow search for objects below the horizons.

  accepts up to 4 arguments:
  - magnitude         - required, integer
  - type              - required, atom
  - mes_only          - optional, boolean. When not specified defaults to false
  - minimum_altitude  - optional, integer. When not specified defaults to zero
  returns a list of objects

  ## Examples
      iex> Astrex.Server.start_link
      iex> Astrex.DeepSky.select_objects(10, :nebulas, true, 25)
      [
        ["NGC6720", "PN", "18:53:35.01", "+33:01:42.9", "Lyr", "9.70", "57"],
        ["NGC6853", "PN", "19:59:36.38", "+22:43:15.7", "Vul", "7.60", "27"]
      ]

    Two Messier nebulas found 25°+ above the horizon at the mock time/mock location

      iex> Astrex.Server.start_link
      iex> Astrex.DeepSky.select_objects(10, :nebulas, 25)
      [
        ["IC0405", "Neb", "05:16:29.48", "+34:21:22.2", "Aur", "10.00", ""],
        ["IC1805", "Cl+N", "02:32:41.51", "+61:27:24.8", "Cas", "7.03", ""],
        ["IC1848", "Cl+N", "02:51:10.59", "+60:24:08.9", "Cas", "6.87", ""],
        ["IC5070", "HII", "20:51:00.72", "+44:24:05.4", "Cyg", "8.00", ""],
        ["IC5146", "Cl+N", "21:53:28.76", "+47:16:00.9", "Cyg", "7.82", ""],
        ["NGC0246", "PN", "00:47:03.36", "-11:52:19.0", "Cet", "8.00", ""],
        ["NGC1499", "Neb", "04:03:14.42", "+36:22:02.9", "Per", "5.00", ""],
        ["NGC1555", "RfN", "04:21:59.43", "+19:32:06.6", "Tau", "9.98", ""],
        ["NGC6543", "PN", "17:58:33.39", "+66:37:59.5", "Dra", "9.79", ""],
        ["NGC6720", "PN", "18:53:35.01", "+33:01:42.9", "Lyr", "9.70", "57"],
        ["NGC6823", "Cl+N", "19:43:09.89", "+23:17:59.8", "Vul", "7.71", ""],
        ["NGC6853", "PN", "19:59:36.38", "+22:43:15.7", "Vul", "7.60", "27"],
        ["NGC6888", "HII", "20:12:06.55", "+38:21:17.8", "Cyg", "7.44", ""],
        ["NGC6960", "SNR", "20:45:58.18", "+30:35:42.5", "Cyg", "7.00", ""],
        ["NGC6992", "SNR", "20:56:19.07", "+31:44:33.9", "Cyg", "7.00", ""],
        ["NGC6995", "SNR", "20:57:10.76", "+31:14:06.6", "Cyg", "7.00", ""],
        ["NGC7000", "HII", "20:59:17.14", "+44:31:43.6", "Cyg", "4.00", ""],
        ["NGC7023", "Neb", "21:01:35.62", "+68:10:10.4", "Cep", "7.20", ""],
        ["NGC7380", "Cl+N", "22:47:21.01", "+58:07:56.7", "Cep", "7.62", ""],
        ["NGC7662", "PN", "23:25:53.90", "+42:32:05.8", "And", "9.20", ""]
      ]

    The same selection returns 20 objects if the Messier requirement is not specified
  """
  @spec select_objects(integer(), atom(), boolean(), integer()) :: list
  def select_objects(magnitude, type, mes_only, minimum_altitude) do
    open_csv()
    |> filter_messier(mes_only)
    |> filter_type(type)
    |> filter_mag(magnitude)
    |> filter_horizon(minimum_altitude)
    # takes all
    |> Enum.to_list()
  end

  def select_objects(magnitude, type, argument) when is_boolean(argument) do
    select_objects(magnitude, type, argument, 0)
  end

  @spec select_objects(integer, atom, boolean | integer) :: list
  def select_objects(magnitude, type, argument) do
    select_objects(magnitude, type, false, argument)
  end

  @spec select_objects(integer, atom) :: list
  def select_objects(magnitude, type) do
    select_objects(magnitude, type, false, 0)
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
      ["Name" | _] -> false
      [_, _, _, _, _, _, _] -> true
    end)
  end

  # Filters out all objects that are lower on the horizon than min_alt degrees
  # min_alt can be negative to capture objects below the horizon
  defp filter_horizon(st, min_alt) do
    Stream.filter(st, fn
      # ra is Hours dec is Degrees
      [_, _, ra_obj, dec_obj | _] ->
        rao = Common.hms2hours(ra_obj) |> Common.hours2deg()
        deco = Common.dms2deg(dec_obj)

        %{alt: alt, az: _az} = Astrex.eq2az(%{ra: rao, dec: deco})

        if alt >= min_alt do
          true
        else
          false
        end
    end)
  end

  # Filters out all objects that are fainter than the specified magnitude
  defp filter_mag(st, magnitude) do
    Stream.filter(st, fn
      [_, _, _, _, _, mag | _] ->
        case Float.parse(mag) do
          {m, _} -> m <= magnitude
          :error -> false
        end
    end)
  end

  # Filters out all objects that are not of the specified type
  defp filter_type(st, type) do
    labels =
      case type do
        :galaxies -> @galaxies
        :open_clusters -> @openclusters
        :globular_clusters -> @globularclusters
        :nebulas -> @nebulas
        _ -> @galaxies ++ @openclusters ++ @globularclusters ++ @nebulas  # no filter applies
      end

    Stream.filter(st, fn
      [_, typ | _] -> Enum.member?(labels, typ)
    end)
  end

  defp filter_messier(st, mes_only) when mes_only == false do
    st
  end

  # Filters out all objects that are not in the Messier catalog
  defp filter_messier(st, _mes_only) do
    Stream.filter(st, fn
      # if messier # not empty -> true
      [_, _, _, _, _, _, mes | _] -> String.length(mes) > 0
    end)
  end

  defp filter_catalog(st, catalog) do
    case catalog do
      :messier ->
        filter_messier(st, true)

      :ngc ->
        Stream.filter(st, fn [cat | _] -> String.starts_with?(cat, "NGC") end)

      :ic ->
        Stream.filter(st, fn [cat | _] -> String.starts_with?(cat, "IC") end)

      _ ->
        false
    end
  end

  defp filter_id(st, id, catalog) do
    case catalog do
      :messier ->
        Stream.filter(st, fn
          [_, _, _, _, _, _, mes | _] ->
            case Integer.parse(mes) do
              {m, _} ->
                m == id

              :error ->
                false
            end
        end)

      _ ->
        Stream.filter(st, fn
          [cat | _] -> String.ends_with?(cat, String.pad_leading(Integer.to_string(id), 4, "0"))
        end)
    end
  end

  # defp objects_to_map(l) do
  #   # TODO
  #   # scan entire list of objects and return a list of maps
  #   # possibly empty list
  # end

  defp object_to_map(obj = [_ | _]) do
    [id | rest] = obj
    [kind | rest] = rest
    [ar | rest] = rest
    [decl | rest] = rest
    [constellation | rest] = rest
    [magnitude | rest] = rest
    [messier | _] = rest

    %{
      id: id,
      kind: kind,
      ar: ar,
      decl: decl,
      constellation: constellation,
      magnitude: magnitude,
      messier: messier
    }
  end

  defp object_to_map([]) do
    %{}
  end

  defp head(l = [_ | _]) do
    hd(l)
  end

  defp head(l = []) do
    l
  end
end
