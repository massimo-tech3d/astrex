defmodule Astrex.Types do
  @type latlong() :: %{lat: float(), long: float()}
  @type altazimuth() :: %{alt: number(), az: number()}
  @type equatorial() :: %{ra: number(), dec: number()}
  @type ecliptical() :: %{longitude: number(), latitude: number()}

  @type solar_system() :: :jupiter |
                          :mars |
                          :mercury |
                          :moon |
                          :neptune |
                          :pluto |
                          :saturn |
                          :sun |
                          :uranus |
                          :venus
end
