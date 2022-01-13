defmodule RclexBench.StringTopic do
  @moduledoc """
    The benchmark for String type.
  """
  require RclexBench
  @eval_loop_num RclexBench.eval_loop_num()
  @eval_interval RclexBench.eval_interval()
  @eval_pub_period RclexBench.eval_pub_period()
  @eval_sub_period RclexBench.eval_sub_period()

  @doc """
    The benchmark which makes any number of publishers.
  """
  def pub_main(filepath, num_node, str_length) do
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

    Process.sleep(@eval_pub_period)

    Rclex.Executor.stop_timer(timer)
    Rclex.Node.finish_jobs(publishers)
    Rclex.Executor.finish_nodes(nodes)
    Rclex.shutdown(context)

    # Write results to the file.
    send(output, {:ok})
  end

  @doc """
    Timer event callback function for publication.
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

    # For debugging to publishing message.
    # IO.puts("[#{time}] published msg: #{message}")

    send(output, {:ok, time})
  end

  @doc """
    The benchmark which makes any number of subscribers.
  """
  def sub_main(filepath, num_node) do
    Logger.configure(level: :info)

    context = Rclex.rclexinit()
    {:ok, nodes} = Rclex.Executor.create_nodes(context, 'sub_node', num_node)
    {:ok, subscribers} = Rclex.Node.create_subscribers(nodes, 'testtopic', :single)

    # Generate file and process for output of measurement logs
    File.write(filepath, "#{filepath}\r\n")
    RclexBench.ResultsServer.start_link(:sub_server, {"", 1})

    # Register callback and start subscription
    Rclex.Subscriber.start_subscribing(subscribers, context, &sub_callback/1)

    Process.sleep(@eval_sub_period)
    Rclex.Subscriber.stop_subscribing(subscribers)
    Rclex.Node.finish_jobs(subscribers)
    Rclex.Executor.finish_nodes(nodes)
    Rclex.shutdown(context)

    # Write results to the file.
    RclexBench.ResultsServer.write(:sub_server, filepath)
    Process.sleep(1000)
    RclexBench.ResultsServer.stop(:sub_server)
  end

  @doc """
    Callback function for subscribers.
  """
  def sub_callback(msg) do
    # Measure system time just after subscribing.
    time = "#{System.system_time(:microsecond)}"
    RclexBench.ResultsServer.store(:sub_server, time)

    # For debugging to subscribing message.
    # received_msg = Rclex.readdata_string(msg)
    # IO.puts("[#{time}] subscribed msg: #{received_msg}")

    msg
  end
end
