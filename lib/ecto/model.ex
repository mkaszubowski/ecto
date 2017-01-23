defmodule EctoOne.Model do
  @moduledoc """
  Warning: this module is currently deprecated. Instead
  `use EctoOne.Schema` and the functions in the `EctoOne` module.

  `EctoOne.Model` is built on top of `EctoOne.Schema`. See
  `EctoOne.Schema` for documentation on the `schema/2` macro,
  as well which fields, associations, types are available.

  ## Using

  When used, `EctoOne.Model` imports itself, as well as the functions
  in `EctoOne.Changeset` and `EctoOne.Query`.

  All the modules existing in `EctoOne.Model.*` are brought in too:

    * `use EctoOne.Model.Callbacks` - provides lifecycle callbacks
    * `use EctoOne.Model.OptimisticLock` - makes the `optimistic_lock/1` macro
      available

  However, you can avoid using `EctoOne.Model` altogether in favor
  of cherry-picking any of the functionality above.
  """

  @doc false
  defmacro __using__(_opts) do
    quote do
      use EctoOne.Schema
      import EctoOne.Model
      import EctoOne.Changeset
      import EctoOne.Query, only: [from: 2]

      use EctoOne.Model.OptimisticLock
      use EctoOne.Model.Callbacks
    end
  end

  @type t :: %{__struct__: atom}

  @doc false
  def primary_key(struct) do
    EctoOne.primary_key(struct)
  end

  @doc false
  def primary_key!(struct) do
    EctoOne.primary_key!(struct)
  end

  @doc false
  def build(struct, assoc, attributes \\ %{}) do
    EctoOne.build_assoc(struct, assoc, attributes)
  end

  @doc false
  def assoc(model_or_models, assoc) do
    EctoOne.assoc(model_or_models, assoc)
  end

  @doc false
  def put_source(model, new_source, new_prefix \\ nil) do
    put_in model.__meta__.source, {new_prefix, new_source}
  end
end
