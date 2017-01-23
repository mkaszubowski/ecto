defprotocol EctoOne.Queryable do
  @moduledoc """
  Converts a data structure into an `EctoOne.Query`.
  """

  @doc """
  Converts the given `data` into an `EctoOne.Query`.
  """
  def to_query(data)
end

defimpl EctoOne.Queryable, for: EctoOne.Query do
  def to_query(query), do: query
end

defimpl EctoOne.Queryable, for: BitString do
  def to_query(source) when is_binary(source),
    do: %EctoOne.Query{from: {source, nil}}
end

defimpl EctoOne.Queryable, for: Atom do
  def to_query(module) do
    try do
      %EctoOne.Query{from: {module.__schema__(:source), module}}
    rescue
      UndefinedFunctionError ->
        message = if :code.is_loaded(module) do
          "the given module is not queryable"
        else
          "the given module does not exist"
        end

        raise Protocol.UndefinedError,
             protocol: @protocol,
                value: module,
          description: message
    end
  end
end

defimpl EctoOne.Queryable, for: Tuple do
  def to_query(from = {source, model}) when is_binary(source) and is_atom(model),
    do: %EctoOne.Query{from: from}
end
