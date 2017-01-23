defmodule EctoOne.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(EctoOne.Migration.Supervisor, [])
    ]

    opts = [strategy: :one_for_one, name: EctoOne.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
