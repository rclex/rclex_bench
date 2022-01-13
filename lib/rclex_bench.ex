defmodule RclexBench do
  @moduledoc """
  Documentation for `RclexBench`.
  """

  # macro definitions for evaluation
  defmacro eval_loop_num, do: 10
  defmacro eval_interval, do: 100
  defmacro eval_period, do: 1_000

  @doc """
  Store result one after another and finally write to the file
  """
  def output(filepath, results, count) do
    receive do
      {:ok, time} ->
        if count <= eval_loop_num() do
          result = "#{count},#{time}\r\n"
          # IO.inspect(result)
          results = results <> result
          output(filepath, results, count + 1)
        end

        output(filepath, results, count + 1)

      {:ok} ->
        File.write(filepath, results, [:append])
    end
  end
end
