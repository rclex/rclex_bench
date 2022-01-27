defmodule RclexBench do
  @moduledoc """
  Documentation for `RclexBench`.
  """

  # macro definitions for evaluation
  defmacro eval_interval, do: 1_000
  defmacro eval_pub_period, do: 9_000
  defmacro eval_sub_period, do: 15_000
  defmacro eval_pub_period_measuring_usage, do: 34_000
  defmacro eval_sub_period_measuring_usage, do: 35_000
  defmacro logger_level, do: :warn
end
