defmodule EctoOne.DateTest do
  use ExUnit.Case, async: true

  @date %EctoOne.Date{year: 2015, month: 12, day: 31}

  test "cast itself" do
    assert EctoOne.Date.cast(@date) == {:ok, @date}
  end

  test "cast strings" do
    assert EctoOne.Date.cast("2015-12-31") == {:ok, @date}
    assert EctoOne.Date.cast("2015-00-23") == :error
    assert EctoOne.Date.cast("2015-13-23") == :error
    assert EctoOne.Date.cast("2015-01-00") == :error
    assert EctoOne.Date.cast("2015-01-32") == :error

    assert EctoOne.Date.cast("2015-12-31 23:50:07") == {:ok, @date}
    assert EctoOne.Date.cast("2015-12-31T23:50:07") == {:ok, @date}
    assert EctoOne.Date.cast("2015-12-31T23:50:07Z") == {:ok, @date}
    assert EctoOne.Date.cast("2015-12-31T23:50:07.000Z") == {:ok, @date}
    assert EctoOne.Date.cast("2015-12-31P23:50:07") == :error

    assert EctoOne.Date.cast("2015-12-31T23:50:07.008") == {:ok, @date}
    assert EctoOne.Date.cast("2015-12-31T23:50:07.008Z") == {:ok, @date}
  end

  test "cast maps" do
    assert EctoOne.Date.cast(%{"year" => "2015", "month" => "12", "day" => "31"}) ==
           {:ok, @date}
    assert EctoOne.Date.cast(%{year: 2015, month: 12, day: 31}) ==
           {:ok, @date}
    assert EctoOne.Date.cast(%{"year" => "2015", "month" => "", "day" => "31"}) ==
           :error
    assert EctoOne.Date.cast(%{"year" => "2015", "month" => nil, "day" => "31"}) ==
           :error
    assert EctoOne.Date.cast(%{"year" => "2015", "month" => nil}) ==
           :error
  end

  test "cast erl date" do
    assert EctoOne.Date.cast({2015, 12, 31}) == {:ok, @date}
    assert EctoOne.Date.cast({2015, 13, 31}) == :error
  end

  test "cast!" do
    assert EctoOne.Date.cast!("2015-12-31") == @date

    assert_raise ArgumentError, "cannot cast \"2015-00-23\" to date", fn ->
      EctoOne.Date.cast!("2015-00-23")
    end
  end

  test "dump itself into a date triplet" do
    assert EctoOne.Date.dump(@date) == {:ok, {2015, 12, 31}}
    assert EctoOne.Date.dump({2015, 12, 31}) == :error
  end

  test "load a date triplet" do
    assert EctoOne.Date.load({2015, 12, 31}) == {:ok, @date}
    assert EctoOne.Date.load(@date) == :error
  end

  test "to_string" do
    assert to_string(@date) == "2015-12-31"
    assert EctoOne.Date.to_string(@date) == "2015-12-31"
  end

  test "to_iso8601" do
    assert EctoOne.Date.to_iso8601(@date) == "2015-12-31"
  end

  test "to_erl and from_erl" do
    assert @date |> EctoOne.Date.to_erl |> EctoOne.Date.from_erl == @date
  end

  test "inspect protocol" do
    assert inspect(@date) == "#EctoOne.Date<2015-12-31>"
  end
end

defmodule EctoOne.TimeTest do
  use ExUnit.Case, async: true

  @time %EctoOne.Time{hour: 23, min: 50, sec: 07, usec: 0}
  @time_zero %EctoOne.Time{hour: 23, min: 50, sec: 0, usec: 0}
  @time_usec %EctoOne.Time{hour: 12, min: 40, sec: 33, usec: 30000}

  test "cast itself" do
    assert EctoOne.Time.cast(@time) == {:ok, @time}
    assert EctoOne.Time.cast(@time_zero) ==  {:ok, @time_zero}
  end

  test "cast strings" do
    assert EctoOne.Time.cast("23:50:07") == {:ok, @time}
    assert EctoOne.Time.cast("23:50:07Z") == {:ok, @time}

    assert EctoOne.Time.cast("23:50:07.030")
      == {:ok, %{@time | usec: 30000}}
    assert EctoOne.Time.cast("23:50:07.123456")
      == {:ok, %{@time | usec: 123456}}
    assert EctoOne.Time.cast("23:50:07.123456Z")
      == {:ok, %{@time | usec: 123456}}
    assert EctoOne.Time.cast("23:50:07.000123Z")
      == {:ok, %{@time | usec: 123}}

    assert EctoOne.Time.cast("24:01:01") == :error
    assert EctoOne.Time.cast("00:61:00") == :error
    assert EctoOne.Time.cast("00:00:61") == :error
    assert EctoOne.Time.cast("00:00:009") == :error
    assert EctoOne.Time.cast("00:00:00.A00") == :error
  end

  test "cast maps" do
    assert EctoOne.Time.cast(%{"hour" => "23", "min" => "50", "sec" => "07"}) ==
           {:ok, @time}
    assert EctoOne.Time.cast(%{hour: 23, min: 50, sec: 07}) ==
           {:ok, @time}
    assert EctoOne.Time.cast(%{"hour" => "23", "min" => "50"}) ==
           {:ok, @time_zero}
    assert EctoOne.Time.cast(%{hour: 23, min: 50}) ==
           {:ok, @time_zero}
    assert EctoOne.Time.cast(%{hour: 12, min: 40, sec: 33, usec: 30_000}) ==
           {:ok, @time_usec}
    assert EctoOne.Time.cast(%{"hour" => 12, "min" => 40, "sec" => 33, "usec" => 30_000}) ==
           {:ok, @time_usec}
    assert EctoOne.Time.cast(%{"hour" => "", "min" => "50"}) ==
           :error
    assert EctoOne.Time.cast(%{hour: 23, min: nil}) ==
           :error
  end

  test "cast tuple" do
    assert EctoOne.Time.cast({23, 50, 07}) == {:ok, @time}
    assert EctoOne.Time.cast({12, 40, 33, 30000}) == {:ok, @time_usec}
    assert EctoOne.Time.cast({00, 61, 33}) == :error
  end

  test "cast!" do
    assert EctoOne.Time.cast!("23:50:07") == @time

    assert_raise ArgumentError, "cannot cast \"24:01:01\" to time", fn ->
      EctoOne.Time.cast!("24:01:01")
    end
  end

  test "dump itself into a time tuple" do
    assert EctoOne.Time.dump(@time) == {:ok, {23, 50, 7, 0}}
    assert EctoOne.Time.dump(@time_usec) == {:ok, {12, 40, 33, 30000}}
    assert EctoOne.Time.dump({23, 50, 07}) == :error
  end

  test "load tuple" do
    assert EctoOne.Time.load({23, 50, 07}) == {:ok, @time}
    assert EctoOne.Time.load({12, 40, 33, 30000}) == {:ok, @time_usec}
    assert EctoOne.Time.load(@time) == :error
  end

  test "to_string" do
    assert to_string(@time) == "23:50:07"
    assert EctoOne.Time.to_string(@time) == "23:50:07"

    assert to_string(@time_usec) == "12:40:33.030000"
    assert EctoOne.Time.to_string(@time_usec) == "12:40:33.030000"

    assert to_string(%EctoOne.Time{hour: 1, min: 2, sec: 3, usec: 4})
           == "01:02:03.000004"
    assert EctoOne.Time.to_string(%EctoOne.Time{hour: 1, min: 2, sec: 3, usec: 4})
           == "01:02:03.000004"
  end

  test "to_iso8601" do
    assert EctoOne.Time.to_iso8601(@time) == "23:50:07"
    assert EctoOne.Time.to_iso8601(@time_usec) == "12:40:33.030000"
  end

  test "to_erl and from_erl" do
    assert @time |> EctoOne.Time.to_erl |> EctoOne.Time.from_erl == @time
  end

  test "inspect protocol" do
    assert inspect(@time) == "#EctoOne.Time<23:50:07>"
    assert inspect(@time_usec) == "#EctoOne.Time<12:40:33.030000>"
  end

  test "precision" do
    assert %EctoOne.Time{usec: 0} = EctoOne.Time.utc
    assert %EctoOne.Time{usec: 0} = EctoOne.Time.utc :sec
  end
end

defmodule EctoOne.DateTimeTest do
  use ExUnit.Case, async: true

  @datetime %EctoOne.DateTime{year: 2015, month: 1, day: 23, hour: 23, min: 50, sec: 07, usec: 0}
  @datetime_zero %EctoOne.DateTime{year: 2015, month: 1, day: 23, hour: 23, min: 50, sec: 0, usec: 0}
  @datetime_usec %EctoOne.DateTime{year: 2015, month: 1, day: 23, hour: 23, min: 50, sec: 07, usec: 8000}
  @datetime_notime %EctoOne.DateTime{year: 2015, month: 1, day: 23, hour: 0, min: 0, sec: 0, usec: 0}

  test "cast itself" do
    assert EctoOne.DateTime.cast(@datetime) == {:ok, @datetime}
    assert EctoOne.DateTime.cast(@datetime_usec) == {:ok, @datetime_usec}
  end

  test "cast strings" do
    assert EctoOne.DateTime.cast("2015-01-23 23:50:07") == {:ok, @datetime}
    assert EctoOne.DateTime.cast("2015-01-23T23:50:07") == {:ok, @datetime}
    assert EctoOne.DateTime.cast("2015-01-23T23:50:07Z") == {:ok, @datetime}
    assert EctoOne.DateTime.cast("2015-01-23T23:50:07.000Z") == {:ok, @datetime}
    assert EctoOne.DateTime.cast("2015-01-23P23:50:07") == :error

    assert EctoOne.DateTime.cast("2015-01-23T23:50:07.008") == {:ok, @datetime_usec}
    assert EctoOne.DateTime.cast("2015-01-23T23:50:07.008Z") == {:ok, @datetime_usec}
    assert EctoOne.DateTime.cast("2015-01-23T23:50:07.008000789") == {:ok, @datetime_usec}
  end

  test "cast maps" do
    assert EctoOne.DateTime.cast(%{"year" => "2015", "month" => "1", "day" => "23",
                                "hour" => "23", "min" => "50", "sec" => "07"}) ==
           {:ok, @datetime}

    assert EctoOne.DateTime.cast(%{year: 2015, month: 1, day: 23, hour: 23, min: 50, sec: 07}) ==
           {:ok, @datetime}

    assert EctoOne.DateTime.cast(%{"year" => "2015", "month" => "1", "day" => "23",
                                "hour" => "23", "min" => "50"}) ==
           {:ok, @datetime_zero}

    assert EctoOne.DateTime.cast(%{year: 2015, month: 1, day: 23, hour: 23, min: 50}) ==
           {:ok, @datetime_zero}

    assert EctoOne.DateTime.cast(%{year: 2015, month: 1, day: 23, hour: 23,
                                min: 50, sec: 07, usec: 8_000}) ==
           {:ok, @datetime_usec}

    assert EctoOne.DateTime.cast(%{"year" => 2015, "month" => 1, "day" => 23,
                                "hour" => 23, "min" => 50, "sec" => 07,
                                "usec" => 8_000}) ==
           {:ok, @datetime_usec}

    assert EctoOne.DateTime.cast(%{"year" => "2015", "month" => "1", "day" => "23",
                                "hour" => "", "min" => "50"}) ==
           :error

    assert EctoOne.DateTime.cast(%{year: 2015, month: 1, day: 23, hour: 23, min: nil}) ==
           :error
  end

  test "cast tuple" do
    assert EctoOne.DateTime.cast({{2015, 1, 23}, {23, 50, 07}}) == {:ok, @datetime}
    assert EctoOne.DateTime.cast({{2015, 1, 23}, {23, 50, 07, 8000}}) == {:ok, @datetime_usec}
    assert EctoOne.DateTime.cast({{2015, 1, 23}, {25, 50, 07, 8000}}) == :error
  end

  test "cast!" do
    assert EctoOne.DateTime.cast!("2015-01-23 23:50:07") == @datetime

    assert_raise ArgumentError, "cannot cast \"2015-01-23P23:50:07\" to datetime", fn ->
      EctoOne.DateTime.cast!("2015-01-23P23:50:07")
    end
  end

  test "dump itself to a tuple" do
    assert EctoOne.DateTime.dump(@datetime) == {:ok, {{2015, 1, 23}, {23, 50, 07, 0}}}
    assert EctoOne.DateTime.dump(@datetime_usec) == {:ok, {{2015, 1, 23}, {23, 50, 07, 8000}}}
    assert EctoOne.DateTime.dump({{2015, 1, 23}, {23, 50, 07}}) == :error
  end

  test "load tuple" do
    assert EctoOne.DateTime.load({{2015, 1, 23}, {23, 50, 07}}) == {:ok, @datetime}
    assert EctoOne.DateTime.load({{2015, 1, 23}, {23, 50, 07, 8000}}) == {:ok, @datetime_usec}
    assert EctoOne.DateTime.load(@datetime) == :error
  end

  test "from_date" do
    assert EctoOne.DateTime.from_date(%EctoOne.Date{year: 2015, month: 1, day: 23}) == @datetime_notime
  end

  test "to_string" do
    assert to_string(@datetime) == "2015-01-23 23:50:07"
    assert EctoOne.DateTime.to_string(@datetime) == "2015-01-23 23:50:07"

    assert to_string(@datetime_usec) == "2015-01-23 23:50:07.008000"
    assert EctoOne.DateTime.to_string(@datetime_usec) == "2015-01-23 23:50:07.008000"
  end

  test "to_iso8601" do
    assert EctoOne.DateTime.to_iso8601(@datetime) == "2015-01-23T23:50:07Z"
    assert EctoOne.DateTime.to_iso8601(@datetime_usec) == "2015-01-23T23:50:07.008000Z"
  end

  test "to_erl and from_erl" do
    assert @datetime |> EctoOne.DateTime.to_erl |> EctoOne.DateTime.from_erl == @datetime
  end

  test "inspect protocol" do
    assert inspect(@datetime) == "#EctoOne.DateTime<2015-01-23T23:50:07Z>"
    assert inspect(@datetime_usec) == "#EctoOne.DateTime<2015-01-23T23:50:07.008000Z>"
  end

  test "precision" do
    assert %EctoOne.DateTime{usec: 0} = EctoOne.DateTime.utc
    assert %EctoOne.DateTime{usec: 0} = EctoOne.DateTime.utc :sec
  end
end
