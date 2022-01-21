defmodule RclexBench do
  @moduledoc """
  Documentation for `RclexBench`.
  """

  # macro definitions for evaluation
  defmacro eval_interval, do: 100
  defmacro eval_pub_period, do: 2_000
  defmacro eval_sub_period, do: 10_000
  defmacro eval_pub_period_measuring_usage, do: 31_000
  defmacro eval_sub_period_measuring_usage, do: 32_000
  defmacro logger_level, do: :warn
end
