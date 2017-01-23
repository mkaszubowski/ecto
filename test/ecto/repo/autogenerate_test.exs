alias EctoOne.TestRepo

defmodule EctoOne.Repo.AutogenerateTest do
  use ExUnit.Case, async: true

  defmodule Default do
    use EctoOne.Schema

    schema "my_model" do
      field :z, EctoOne.UUID, autogenerate: true
      timestamps
    end
  end

  defmodule Config do
    use EctoOne.Schema

    @timestamps_opts [inserted_at: :created_on]
    schema "default" do
      timestamps updated_at: :updated_on
    end
  end

  ## Autogenerate

  @uuid "30313233-3435-3637-3839-616263646566"

  test "autogenerates values" do
    model = TestRepo.insert!(%Default{})
    assert byte_size(model.z) == 36

    changeset = EctoOne.Changeset.cast(%Default{}, %{}, [], [])
    model = TestRepo.insert!(changeset)
    assert byte_size(model.z) == 36

    changeset = EctoOne.Changeset.cast(%Default{}, %{z: nil}, [], [])
    model = TestRepo.insert!(changeset)
    assert byte_size(model.z) == 36

    changeset = EctoOne.Changeset.cast(%Default{}, %{z: @uuid}, [:z], [])
    model = TestRepo.insert!(changeset)
    assert model.z == @uuid
  end

  ## Timestamps

  test "sets inserted_at and updated_at values" do
    default = TestRepo.insert!(%Default{})
    assert %EctoOne.DateTime{} = default.inserted_at
    assert %EctoOne.DateTime{} = default.updated_at

    default = TestRepo.update!(%Default{id: 1} |> EctoOne.Changeset.change, force: true)
    refute default.inserted_at
    assert %EctoOne.DateTime{} = default.updated_at
  end

  test "does not set inserted_at and updated_at values if they were previously set" do
    default = TestRepo.insert!(%Default{inserted_at: %EctoOne.DateTime{year: 2000},
                                        updated_at: %EctoOne.DateTime{year: 2000}})
    assert default.inserted_at == %EctoOne.DateTime{year: 2000}
    assert default.updated_at == %EctoOne.DateTime{year: 2000}

    changeset = EctoOne.Changeset.change(%Default{id: 1}, updated_at: %EctoOne.DateTime{year: 2000})
    default = TestRepo.update!(changeset)
    refute default.inserted_at
    assert default.updated_at == %EctoOne.DateTime{year: 2000}
  end

  test "sets custom inserted_at and updated_at values" do
    default = TestRepo.insert!(%Config{})
    assert %EctoOne.DateTime{} = default.created_on
    assert %EctoOne.DateTime{} = default.updated_on

    default = TestRepo.update!(%Config{id: 1} |> EctoOne.Changeset.change, force: true)
    refute default.created_on
    assert %EctoOne.DateTime{} = default.updated_on
  end
end
