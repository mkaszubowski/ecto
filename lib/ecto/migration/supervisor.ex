defmodule EctoOne.Migration.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(EctoOne.Migration.Runner, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end