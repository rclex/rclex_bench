defmodule RclexBench.StringTopicCm do
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
  def pub_main(filepath, num_node, num_comm) do
    Logger.configure(level: @logger_level)

    # Generate file for measurement logs.
    File.write(filepath, "")
    # Start ResultsServer for publisher.
    RclexBench.ResultsServer.start_link(:pub_server, "")

    # Create nodes and register them as publishers.
    context = Rclex.rclexinit()
    {:ok, nodes} = Rclex.ResourceServer.create_nodes(context, 'pub_node', num_node)
    {:ok, publishers} = Rclex.Node.create_publishers(nodes, 'StdMsgs.Msg.String', 'testtopic', :single)

    # Create and start Rclex Timer for publication.
    {:ok, timer} =
      Rclex.ResourceServer.create_timer(
        &pub_callback/1,
        publishers,
        @eval_interval,
        num_comm
      )

    # Wait a while to finish publication.
    Process.sleep(@eval_pub_period)

    # Finalize Rclex environments.
    Rclex.ResourceServer.stop_timer(timer)
    Rclex.Node.finish_jobs(publishers)
    Rclex.ResourceServer.finish_nodes(nodes)
    Rclex.shutdown(context)

    # Write results to the file.
    RclexBench.ResultsServer.write(:pub_server, filepath)
    Process.sleep(1000)
    RclexBench.ResultsServer.stop(:pub_server)
  end

  @doc """
    Timer event callback function for publication.
  """
  def pub_callback(publishers) do
    n = length(publishers)

    # Generate message values according to the number of publishers.
    values =
      Enum.map(0..(n - 1), fn _ ->
        Enum.map(0..5, fn _ ->
          :rand.uniform_real * 2.0
        end)
      end)

    # Measuring system time before preparing message.
    time = "#{System.system_time(:microsecond)}"

    # Prepare messages.
    messages =
      Enum.map(values, fn [linear_x, linear_y, linear_z, angular_x, angular_y, angular_z] ->
        %Rclex.StdMsgs.Msg.String{data: Float.to_charlist(linear_x) ++ ',' ++ Float.to_charlist(linear_y) ++ ',' ++ Float.to_charlist(linear_z) ++ ',' ++ Float.to_charlist(angular_x) ++ ',' ++ Float.to_charlist(angular_y) ++ ',' ++ Float.to_charlist(angular_z)}
      end)

    # Convert messages to ROS format.
    msg_list = Rclex.Msg.initialize_msgs(n, 'StdMsgs.Msg.String')

    Enum.map(0..(n - 1), fn index ->
      Rclex.Msg.set(Enum.at(msg_list, index), Enum.at(messages, index), 'StdMsgs.Msg.String')
    end)

    # Publish topics.
    Rclex.Publisher.publish(publishers, msg_list)

    ## For debugging to publishing message.
    # IO.puts("[#{time}] published msg: #{message}")

    # Store time to ResultsServer.
    Enum.map(0..(n - 1), fn index ->
      RclexBench.ResultsServer.store(:pub_server, "#{Enum.at(messages, index).data}@#{time}\r\n")
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
    {:ok, nodes} = Rclex.ResourceServer.create_nodes(context, 'sub_node', num_node)
    {:ok, subscribers} = Rclex.Node.create_subscribers(nodes, 'StdMsgs.Msg.String', 'testtopic', :single)

    # Register callback and start subscription.
    Rclex.Subscriber.start_subscribing(subscribers, context, &sub_callback/1)

    # Wait a while to finish publication.
    Process.sleep(@eval_sub_period)

    # Finalize Rclex environments.
    Rclex.Subscriber.stop_subscribing(subscribers)
    Rclex.Node.finish_jobs(subscribers)
    Rclex.ResourceServer.finish_nodes(nodes)
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
    # Read received message.
    recv_msg = Rclex.Msg.read(msg, 'StdMsgs.Msg.String')
    [linear_x, linear_y, linear_z, angular_x, angular_y, angular_z] =
      List.to_string(recv_msg.data)
      |> String.split(",")
      |> Enum.map(fn str_value ->
           Float.parse(str_value)
         end)

    # Measure system time after reading message.
    time = "#{System.system_time(:microsecond)}"

    RclexBench.ResultsServer.store(:sub_server, "#{recv_msg.data}@#{time}\r\n")
    ## For debugging to subscribing message.
    # IO.puts("[#{time}] subscribed msg: #{recv_msg}")
  end
end
