defmodule RclexBench.StringTopic do
  @moduledoc """
    The benchmark for String type.
  """
  require RclexBench
  @eval_interval RclexBench.eval_interval()
  @eval_pub_period RclexBench.eval_pub_period()
  @eval_sub_period RclexBench.eval_sub_period()
  @logger_level RclexBench.logger_level()

  @doc """
    The benchmark which makes any number of publishers.
  """
  def pub_main(filepath, num_node, str_length, num_comm) do
    Logger.configure(level: @logger_level)

    # Generate file for measurement logs.
    File.write(filepath, "")
    # Start ResultsServer for publisher.
    RclexBench.ResultsServer.start_link(:pub_server, "")

    # Create nodes and register them as publishers.
    context = Rclex.rclexinit()
    {:ok, nodes} = Rclex.Executor.create_nodes(context, 'pub_node', num_node)
    {:ok, publishers} = Rclex.Node.create_publishers(nodes, 'testtopic', :single)

    # Create and start Rclex Timer for publication.
    {:ok, timer} =
      Rclex.Executor.create_timer(
        &pub_callback/1,
        {publishers, str_length},
        @eval_interval,
        num_comm
      )

    # Wait a while to finish publication.
    Process.sleep(@eval_pub_period)

    # Finalize Rclex environments.
    Rclex.Executor.stop_timer(timer)
    Rclex.Node.finish_jobs(publishers)
    Rclex.Executor.finish_nodes(nodes)
    Rclex.shutdown(context)

    # Write results to the file.
    RclexBench.ResultsServer.write(:pub_server, filepath)
    Process.sleep(1000)
    RclexBench.ResultsServer.stop(:pub_server)
  end

  @doc """
    Timer event callback function for publication.
  """
  def pub_callback(args) do
    {publishers, length} = args
    n = length(publishers)

    # Prepare messages according to the number of publishers.
    messages =
      Enum.map(0..(n - 1), fn _ ->
        RclexBench.Utils.random_string(length)
      end)

    # Convert messages to ROS format
    msg_list = Rclex.initialize_msgs(n, :string)

    Enum.map(0..(n - 1), fn index ->
      Rclex.setdata(Enum.at(msg_list, index), Enum.at(messages, index), :string)
    end)

    # Publish topics after measuring system time.
    time = "#{System.system_time(:microsecond)}"
    Rclex.Publisher.publish(publishers, msg_list)

    ## For debugging to publishing message.
    # IO.puts("[#{time}] published msg: #{message}")

    # Store time to ResultsServer.
    Enum.map(0..(n - 1), fn index ->
      RclexBench.ResultsServer.store(:pub_server, "#{Enum.at(messages, index)},#{time}\r\n")
    end)
  end

  @doc """
    The benchmark which makes any number of subscribers.
  """
  def sub_main(filepath, num_node) do
    Logger.configure(level: @logger_level)

    # Generate file for measurement logs.
    File.write(filepath, "")
    # Start ResultsServer for subscriber.
    RclexBench.ResultsServer.start_link(:sub_server, "")

    # Create nodes and register them as subscribers.
    context = Rclex.rclexinit()
    {:ok, nodes} = Rclex.Executor.create_nodes(context, 'sub_node', num_node)
    {:ok, subscribers} = Rclex.Node.create_subscribers(nodes, 'testtopic', :single)

    # Register callback and start subscription.
    Rclex.Subscriber.start_subscribing(subscribers, context, &sub_callback/1)

    # Wait a while to finish publication.
    Process.sleep(@eval_sub_period)

    # Finalize Rclex environments.
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

    recv_msg = Rclex.readdata_string(msg)
    RclexBench.ResultsServer.store(:sub_server, "#{recv_msg},#{time}\r\n")
    ## For debugging to subscribing message.
    # IO.puts("[#{time}] subscribed msg: #{recv_msg}")
  end
end
