defmodule Astrex.SolarSystemTest do
  # , async: true
  use ExUnit.Case

  test "altazimuth to equatorial" do
    Astrex.start_link()

    {ra, dec} = Astrex.Calculations.az2eq({45.5, 9.15})
    assert_in_delta(ra, 4.74521, 0.01)
    assert_in_delta(dec, 7.29868, 0.01)
  end

  test "equatorial to altazimuth" do
    Astrex.start_link()

    {alt, az} = Astrex.Calculations.eq2az({4.74, 7.3})
    assert_in_delta(alt, 45.5, 0.01)
    assert_in_delta(az, 9.15, 0.01)
  end

  # this one fails
  test "round trip az2eq2az" do
    Astrex.start_link()
    {ialt, iaz} = {72.75, 15.36}

    {falt, faz} = Astrex.Calculations.az2eq({ialt, iaz}) |> Astrex.Calculations.eq2az()
    assert_in_delta(ialt, falt, 0.01)
    assert_in_delta(iaz, faz, 0.01)
  end

  # this one fails
  test "round trip eq2az2eq" do
    Astrex.start_link()
    {ira, idec} = {72.75, 54.36}

    {fra, fdec} = Astrex.Calculations.eq2az({ira, idec}) |> Astrex.Calculations.az2eq()
    assert_in_delta(ira, fra, 0.01)
    assert_in_delta(idec, fdec, 0.01)
  end

  # this one passes
  test "second round trip az2eq2az" do
    Astrex.start_link()
    {ialt, iaz} = {45.5, 122.15}

    {falt, faz} = Astrex.Calculations.az2eq({ialt, iaz}) |> Astrex.Calculations.eq2az()
    assert_in_delta(ialt, falt, 0.01)
    assert_in_delta(iaz, faz, 0.01)
  end

  # this one passes
  test "second round trip eq2az2eq" do
    Astrex.start_link()
    {ira, idec} = {4.74, 7.3}

    {fra, fdec} = Astrex.Calculations.eq2az({ira, idec}) |> Astrex.Calculations.az2eq()
    assert_in_delta(ira, fra, 0.01)
    assert_in_delta(idec, fdec, 0.01)
  end

  # this one passes
  test "third round trip az2eq2az" do
    Astrex.start_link()
    {ialt, iaz} = {-45.5, 215.15}

    {falt, faz} = Astrex.Calculations.az2eq({ialt, iaz}) |> Astrex.Calculations.eq2az()
    assert_in_delta(ialt, falt, 0.01)
    assert_in_delta(iaz, faz, 0.01)
  end

  # this one passes
  test "third round trip eq2az2eq" do
    Astrex.start_link()
    {ira, idec} = {227.74, 87.3}

    {fra, fdec} = Astrex.Calculations.eq2az({ira, idec}) |> Astrex.Calculations.az2eq()
    assert_in_delta(ira, fra, 0.01)
    assert_in_delta(idec, fdec, 0.01)
  end

  # this one passes
  test "fourth round trip az2eq2az" do
    Astrex.start_link()
    {ialt, iaz} = {12.5, 310.15}

    {falt, faz} = Astrex.Calculations.az2eq({ialt, iaz}) |> Astrex.Calculations.eq2az()
    assert_in_delta(ialt, falt, 0.01)
    assert_in_delta(iaz, faz, 0.01)
  end

  # this one passes
  test "fourth round trip eq2az2eq" do
    Astrex.start_link()
    {ira, idec} = {354.74, -27.3}

    {fra, fdec} = Astrex.Calculations.eq2az({ira, idec}) |> Astrex.Calculations.az2eq()
    assert_in_delta(ira, fra, 0.01)
    assert_in_delta(idec, fdec, 0.01)
  end
end
