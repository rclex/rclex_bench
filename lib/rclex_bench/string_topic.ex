defmodule RclexBench.StringTopic do
  require RclexBench
  @eval_loop_num RclexBench.eval_loop_num()
  @eval_interval RclexBench.eval_interval()
  @eval_period RclexBench.eval_period()

  @moduledoc """
    The sample which makes any number of publishers.
  """
  def pub_main(filepath, str_length, num_node) do
    Logger.configure(level: :info)

    context = Rclex.rclexinit()
    {:ok, nodes} = Rclex.Executor.create_nodes(context, 'pub_node', num_node)
    {:ok, publishers} = Rclex.Node.create_publishers(nodes, 'testtopic', :single)

    # Generate file and process for output of measurement logs
    File.write(filepath, "#{filepath}\r\n")
    output = spawn(RclexBench, :output, [filepath, "", 1])

    # Prepare string message to publish
    message = String.duplicate("a", str_length)

    # Create and start Rclex Timer for publication
    {:ok, timer} =
      Rclex.Executor.create_timer(
        &pub_callback/1,
        [publishers, message, output],
        @eval_interval,
        @eval_loop_num
      )

    Process.sleep(@eval_period)
    Rclex.Executor.stop_timer(timer)
    Rclex.Node.finish_jobs(publishers)
    Rclex.Executor.finish_nodes(nodes)
    Rclex.shutdown(context)

    send(output, {:ok})
  end

  @doc """
    Timer event callback function defined by user.
  """
  def pub_callback(args) do
    [publishers, message, output] = args

    # Prepare messages according to the number of publishers.
    n = length(publishers)
    msg_list = Rclex.initialize_msgs(n, :string)

    Enum.map(0..(n - 1), fn index ->
      Rclex.setdata(Enum.at(msg_list, index), message, :string)
    end)

    # Publish topics after measuring system time
    time = "#{System.system_time(:microsecond)}"
    Rclex.Publisher.publish(publishers, msg_list)

    send(output, {:ok, time})
  end
end
