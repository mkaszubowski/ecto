defprotocol EctoOne.DataType do
  @moduledoc """
  Casts a given data type into an `EctoOne.Type`.

  While `EctoOne.Type` allows developers to cast/load/dump
  any value from the storage into the struct based on the
  schema, `EctoOne.DataType` allows developers to convert
  existing data types into existing EctoOne types, be them
  primitive or custom.

  For example, `EctoOne.Date` is a custom type, represented
  by the `%EctoOne.Date{}` struct that can be used in place
  of EctoOne's primitive `:date` type. Therefore, we need to
  tell EctoOne how to convert `%EctoOne.Date{}` into `:date` and
  such is done with the `EctoOne.DataType` protocol:

      defimpl EctoOne.DataType, for: EctoOne.DateTime do
        def cast(%EctoOne.Date{day: day, month: month, year: year}, :date) do
          {:ok, {year, month, day}}
        end
        def cast(_, _) do
          :error
        end
      end

  """
  @fallback_to_any true
  def cast(value, type)
end

defimpl EctoOne.DataType, for: Any do
  def cast(_value, _type) do
    :error
  end
end
