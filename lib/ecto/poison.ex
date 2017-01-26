if Code.ensure_loaded?(Poison) do
  defimpl Poison.Encoder, for: [EctoOne.Date, EctoOne.Time, EctoOne.DateTime] do
    def encode(dt, _opts), do: <<?", @for.to_iso8601(dt)::binary, ?">>
  end
end
