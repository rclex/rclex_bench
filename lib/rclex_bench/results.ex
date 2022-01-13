defmodule RclexBench.Results do
  use GenServer

  def init({results, count}) do
    {:ok, {results, count}}
  end

  def handle_cast({:store, time}, {results, count}) do
    result = "#{count},#{time}\r\n"
    # IO.inspect(result)
    results = results <> result
    {:noreply, {results, count + 1}}
  end

  def handle_cast({:write, filepath}, {results, count}) do
    # IO.inspect(results)
    File.write(filepath, results, [:append])
    {:noreply, {results, count}}
  end

  def start_link(name, {results, count}) do
    GenServer.start_link(__MODULE__, {results, count}, name: name)
  end

  def store(name, time) do
    GenServer.cast(name, {:store, time})
  end

  def write(name, filepath) do
    GenServer.cast(name, {:write, filepath})
  end

  def stop(name) do
    GenServer.stop(name, :normal)
  end
end
