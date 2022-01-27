defmodule RclexBench.StringTopicForMeasuringUsage do
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

    # Create nodes and register them as publishers.
    context = Rclex.rclexinit()
    nodes = Rclex.create_nodes(context, 'pub_node', num_node)
    publishers = Rclex.create_publishers(nodes, 'testtopic', :single)

    # Create and start Rclex Timer for publication.
    {_pub_sv, _pub_child} =
      Rclex.Timer.timer_start(
        {publishers, str_length},
        @eval_interval,
        &pub_callback/1
      )

    # Wait a while to finish publication.
    Process.sleep(@eval_pub_period)

    # Finalize Rclex environments.
    Rclex.publisher_finish(publishers, nodes)
    Rclex.node_finish(nodes)
    Rclex.shutdown(context)
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
  end

  @doc """
    The benchmark which makes any number of subscribers.
  """
  def sub_main(filepath, num_node) do
    Logger.configure(level: @logger_level)

    # Create nodes and register them as subscribers.
    context = Rclex.rclexinit()
    nodes = Rclex.create_nodes(context, 'sub_node', num_node)
    subscribers = Rclex.create_subscribers(nodes, 'testtopic', :single)

    # Register callback and start subscription.
    {sv, child} = Rclex.Subscriber.subscribe_start(subscribers, context, &sub_callback/1)

    # Wait a while to finish publication.
    Process.sleep(@eval_sub_period)

    # Finalize Rclex environments.
    Rclex.Timer.terminate_timer(sv, child)
    Rclex.subscriber_finish(subscribers, nodes)
    Rclex.node_finish(nodes)
    Rclex.shutdown(context)
  end

  @doc """
    Callback function for subscribers.
  """
  def sub_callback(_msg) do
  end
end
