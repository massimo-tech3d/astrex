defmodule Astrex.Astro.Refraction do
  # Meeus Atmospheric refraction - chapter 16
  @moduledoc """
    Refraction can change significantly the apparent altitude of an object.
    The change depends solely on the altitude and is maximun on the
    horizon (objects may appear above the horizon when they are
    actually still below) and zero at the zenith

    This module exports functions to calculate the true altitude
    given the apparent one, and to calculate the apparent altitude
    if the true one is known - typically calculated starting from
    equatorial coordinate system.

    The algorithms are taken from Jean Meeus book: "Astronomical Algorithms"
    Chapter 16 - Atmospheric Refraction
  """
  import Math

  alias Astrex.Types, as: T

  @doc """
    Receives a T.altazimuth map including the apparent altitude
    Returns a T.altazimuth map including the true altitude

    The apparent altitude corresponds to the digital setting circles readings
    The true altitude allows to precisely calculate the equatorial coordinates
    of the point the telescope is aiming at.

  ## Examples
      iex> Astrex.Astro.Refraction.true_alt(%{alt: 45, az: 180})
      %{alt: 44.98341920053572, az: 180}
  """
  @spec true_alt(T.altazimuth()) :: T.altazimuth()
  def true_alt(%{alt: apparent_alt, az: az}) do
    alt = apparent_alt
    term = alt + 7.31 / (alt + 4.4)
    # rr is expressed in minutes of arc
    rr = (1 / tan(term |> deg2rad)) |> min2deg
    # correction term still to be added see page 106
    %{alt: alt - rr, az: az}
  end

  @doc """
    Receives a T.altazimuth map including the true altitude.
    Returns a T.altazimuth map including the apparent altitude.

    The true altitude is calculated from the equatorial coordinates of the object.
    The apparent altitude corresponds to where the digital setting circles must aim
    to center the object

  ## Examples
      iex> Astrex.Astro.Refraction.apparent_alt(%{alt: 45, az: 180})
      %{alt: 45.016878460981225, az: 180}
  """
  @spec apparent_alt(T.altazimuth()) :: T.altazimuth()
  def apparent_alt(%{alt: true_alt, az: az}) do
    alt = true_alt
    term = alt + 10.3 / (alt + 5.11)
    # rr is expressed in minutes of arc
    rr = (1.02 / tan(term |> deg2rad)) |> min2deg
    %{alt: alt + rr, az: az}
  end

  defp min2deg(d) do
    d / 60
  end
end
