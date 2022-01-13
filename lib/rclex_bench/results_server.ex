defmodule RclexBench.ResultsServer do
  use GenServer

  def start_link(name, results) do
    GenServer.start_link(__MODULE__, results, name: name)
  end

  def init(results) do
    {:ok, results}
  end

  def handle_cast({:store, time}, results) do
    result = "#{time}\r\n"
    # IO.inspect(result)
    {:noreply, results <> result}
  end

  def handle_call({:write, filepath}, _from, results) do
    # IO.inspect(results)
    File.write(filepath, results, [:append])
    {:reply, nil, results}
  end

  def store(name, time) do
    GenServer.cast(name, {:store, time})
  end

  def write(name, filepath) do
    GenServer.call(name, {:write, filepath})
  end

  def stop(name) do
    GenServer.stop(name, :normal)
  end
end
