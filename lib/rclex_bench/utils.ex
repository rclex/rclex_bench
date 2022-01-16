defmodule RclexBench.Utils do
  @moduledoc """
    The utility for RclexBench
  """

  def random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.encode64() |> binary_part(0, length)
  end

  def aggregation_csv(pub_file, sub_file, out_file) do
    pub_rows = trim_csv(pub_file)
    sub_rows = trim_csv(sub_file)

    File.write(out_file, "")
    RclexBench.ResultsServer.start_link(:agg_server, "")

    for [pub_msg, pub_time] <- pub_rows do
      RclexBench.ResultsServer.store(:agg_server, "#{pub_msg}")

      for [sub_msg, sub_time] <- sub_rows do
        if pub_msg == sub_msg do
          RclexBench.ResultsServer.store(:agg_server, "@#{sub_time - pub_time}")
        end
      end

      RclexBench.ResultsServer.store(:agg_server, "\r\n")
    end

    RclexBench.ResultsServer.write(:agg_server, out_file)
  end

  defp trim_csv(file) do
    rows =
      file
      |> File.stream!()
      |> Stream.map(&String.trim(&1))
      |> Stream.map(&String.split(&1, "@"))
      |> Enum.to_list()

    Enum.map(rows, fn [msg, time_string] ->
      time = String.to_integer(time_string)
      [msg, time]
    end)
  end
end
