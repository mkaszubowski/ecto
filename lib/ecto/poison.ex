if Code.ensure_loaded?(Poison) do
  unless Code.ensure_compiled?(Poison.Encoder.Decimal) do
    defimpl Poison.Encoder, for: Decimal do
      def encode(decimal, _opts), do: <<?", Decimal.to_string(decimal)::binary, ?">>
    end
  end

  defimpl Poison.Encoder, for: [EctoOne.Date, EctoOne.Time, EctoOne.DateTime] do
    def encode(dt, _opts), do: <<?", @for.to_iso8601(dt)::binary, ?">>
  end
end
