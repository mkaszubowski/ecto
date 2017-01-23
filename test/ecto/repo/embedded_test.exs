defmodule EctoOne.Repo.EmbeddedTest do
  use ExUnit.Case, async: true

  alias EctoOne.TestRepo, as: TestRepo

  defmodule SubEmbed do
    use EctoOne.Schema

    @primary_key {:id, :binary_id, autogenerate: true}
    schema "" do
      field :y, :string
    end
  end

  defmodule MyEmbed do
    use EctoOne.Schema

    @primary_key {:id, :binary_id, autogenerate: true}
    schema "" do
      field :x, :string
      embeds_one :sub_embed, SubEmbed, on_replace: :delete
      timestamps
    end
  end

  defmodule MyModel do
    use EctoOne.Schema

    schema "my_model" do
      embeds_one :embed, MyEmbed, on_replace: :delete
      embeds_many :embeds, MyEmbed, on_replace: :delete
    end
  end

  @uuid "30313233-3435-3637-3839-616263646566"

  test "cannot change embeds on update_all" do
    changeset = EctoOne.Changeset.change(%MyEmbed{})
    assert catch_error(TestRepo.update_all MyModel, set: [embed: %MyEmbed{}])
    assert catch_error(TestRepo.update_all MyModel, set: [embed: changeset])
  end

  ## insert

  test "adds embeds to changeset as empty on insert" do
    model = TestRepo.insert!(%MyModel{})
    assert model.embed == nil
    assert model.embeds == []
  end

  test "handles embeds on insert" do
    embed = %MyEmbed{x: "xyz"}

    changeset = 
      %MyModel{}
      |> EctoOne.Changeset.change
      |> EctoOne.Changeset.put_embed(:embed, embed)
    model = TestRepo.insert!(changeset)
    embed = model.embed
    assert embed.id
    assert embed.x == "xyz"
    assert embed.inserted_at

    changeset =
      %MyModel{}
      |> EctoOne.Changeset.change
      |> EctoOne.Changeset.put_embed(:embeds, [embed])
    model = TestRepo.insert!(changeset)
    [embed] = model.embeds
    assert embed.id
    assert embed.x == "xyz"
    assert embed.inserted_at
  end

  test "raises when embed is given on insert" do
    assert_raise ArgumentError, ~r"set for embed named `embed`", fn ->
      TestRepo.insert!(%MyModel{embed: %MyEmbed{x: "xyz"}})
    end

    assert_raise ArgumentError, ~r"set for embed named `embeds`", fn ->
      TestRepo.insert!(%MyModel{embeds: [%MyEmbed{x: "xyz"}]})
    end
  end

  test "raises on action mismatch on insert" do
    changeset =
      %MyModel{}
      |> EctoOne.Changeset.change()
      |> EctoOne.Changeset.put_embed(:embed, %MyEmbed{x: "xyz"})
    changeset = put_in(changeset.changes.embed.action, :update)
    assert_raise ArgumentError, ~r"got action :update in changeset for embedded .* while inserting", fn ->
      TestRepo.insert!(changeset)
    end
  end

  test "returns untouched changeset on constraint mismatch on insert" do
    changeset =
      put_in(%MyModel{}.__meta__.context, {:invalid, [unique: "my_model_foo_index"]})
      |> EctoOne.Changeset.change()
      |> EctoOne.Changeset.put_embed(:embed, %MyEmbed{x: "xyz"})
      |> EctoOne.Changeset.unique_constraint(:foo)
    assert {:error, changeset} = TestRepo.insert(changeset)
    assert_received {:rollback, ^changeset}
    assert changeset.model.__meta__.state == :built
    refute changeset.model.embed
    assert changeset.changes.embed
    refute changeset.changes.embed.model.id
    refute changeset.valid?
  end

  test "handles nested embeds on insert" do
    embed =
      %MyEmbed{x: "xyz"}
      |> EctoOne.Changeset.change()
      |> EctoOne.Changeset.put_embed(:sub_embed, %SubEmbed{y: "xyz"})
    changeset =
      %MyModel{}
      |> EctoOne.Changeset.change()
      |> EctoOne.Changeset.put_embed(:embed, embed)
    model = TestRepo.insert!(changeset)
    assert model.embed.sub_embed.id
  end

  ## update

  test "skips embeds on update when not changing" do
    embed = %MyEmbed{x: "xyz"}

    # If embed is not in changeset, embeds are left out
    changeset = EctoOne.Changeset.change(%MyModel{id: 1, embed: embed}, x: "abc")
    model = TestRepo.update!(changeset)
    assert model.embed == embed

    changeset = EctoOne.Changeset.change(%MyModel{id: 1, embeds: [embed]}, x: "abc")
    model = TestRepo.update!(changeset)
    assert model.embeds == [embed]
  end

  test "inserting embeds on update" do
    embed = %MyEmbed{x: "xyz"}

    changeset =
      %MyModel{id: 1}
      |> EctoOne.Changeset.change
      |> EctoOne.Changeset.put_embed(:embed, embed)
    model = TestRepo.update!(changeset)
    embed = model.embed
    assert embed.id
    assert embed.x == "xyz"
    assert embed.updated_at

    changeset =
      %MyModel{id: 1}
      |> EctoOne.Changeset.change
      |> EctoOne.Changeset.put_embed(:embeds, [embed])
    model = TestRepo.update!(changeset)
    [embed] = model.embeds
    assert embed.id
    assert embed.x == "xyz"
    assert embed.updated_at
  end

  test "replacing embeds on update" do
    embed = %MyEmbed{x: "xyz", id: @uuid}

    # Replacing embed with a new one
    new_embed = %MyEmbed{x: "abc"}
    changeset =
      %MyModel{id: 1, embed: embed}
      |> EctoOne.Changeset.change
      |> EctoOne.Changeset.put_embed(:embed, new_embed)
    model = TestRepo.update!(changeset)
    embed = model.embed
    assert embed.id != @uuid
    assert embed.x == "abc"
    assert embed.inserted_at
    assert embed.updated_at

    # Replacing embed with nil
    changeset =
      %MyModel{id: 1, embed: embed}
      |> EctoOne.Changeset.change
      |> EctoOne.Changeset.put_embed(:embed, nil)
    model = TestRepo.update!(changeset)
    refute model.embed
  end

  test "changing embeds on update raises if there is no id" do
    embed = %MyEmbed{x: "xyz"}

    # Raises if there's no id
    embed_changeset = EctoOne.Changeset.change(embed, x: "abc")
    changeset =
      %MyModel{id: 1, embed: embed}
      |> EctoOne.Changeset.change
      |> EctoOne.Changeset.put_embed(:embed, embed_changeset)
    assert_raise EctoOne.NoPrimaryKeyValueError, fn ->
      TestRepo.update!(changeset)
    end
  end

  test "changing embeds on update" do
    sample = %MyEmbed{x: "xyz", id: @uuid}
    sample_changeset = EctoOne.Changeset.change(sample, x: "abc")

    changeset =
      %MyModel{id: 1, embed: sample}
      |> EctoOne.Changeset.change
      |> EctoOne.Changeset.put_embed(:embed, sample_changeset)
    model = TestRepo.update!(changeset)
    embed = model.embed
    assert embed.id == @uuid
    assert embed.x == "abc"
    refute embed.inserted_at
    assert embed.updated_at

    changeset =
      %MyModel{id: 1, embeds: [sample]}
      |> EctoOne.Changeset.change
      |> EctoOne.Changeset.put_embed(:embeds, [sample_changeset])
    model = TestRepo.update!(changeset)
    [embed] = model.embeds
    assert embed.id == @uuid
    assert embed.x == "abc"
    refute embed.inserted_at
    assert embed.updated_at
  end

  test "empty changeset on update" do
    embed = %MyEmbed{x: "xyz", id: @uuid}
    no_changes = EctoOne.Changeset.change(embed)

    changeset =
      %MyModel{id: 1, embed: embed}
      |> EctoOne.Changeset.change(x: "abc")
      |> EctoOne.Changeset.put_embed(:embed, no_changes)
    model = TestRepo.update!(changeset)
    refute model.embed.updated_at

    changes = EctoOne.Changeset.change(embed, x: "abc")
    changeset =
      %MyModel{id: 1, embeds: [embed]}
      |> EctoOne.Changeset.change
      |> EctoOne.Changeset.put_embed(:embeds, [no_changes, changes])
    model = TestRepo.update!(changeset)
    refute hd(model.embeds).updated_at
  end

  test "removing embeds on update raises if there is no id" do
    embed = %MyEmbed{x: "xyz"}

    changeset =
      %MyModel{id: 1, embed: embed}
      |> EctoOne.Changeset.change
      |> EctoOne.Changeset.put_embed(:embed, nil)
    assert_raise EctoOne.NoPrimaryKeyValueError, fn ->
      TestRepo.update!(changeset)
    end
  end

  test "removing embeds on update" do
    embed = %MyEmbed{x: "xyz", id: @uuid}

    changeset =
      %MyModel{id: 1, embed: embed}
      |> EctoOne.Changeset.change
      |> EctoOne.Changeset.put_embed(:embed, nil)
    model = TestRepo.update!(changeset)
    assert model.embed == nil

    changeset =
      %MyModel{id: 1, embeds: [embed]}
      |> EctoOne.Changeset.change
      |> EctoOne.Changeset.put_embed(:embeds, [])
    model = TestRepo.update!(changeset)
    assert model.embeds == []
  end

  test "returns untouched changeset on constraint mismatch on update" do
    embed = %MyEmbed{x: "xyz"}

    my_model = %MyModel{id: 1, embed: nil}
    changeset =
      put_in(my_model.__meta__.context, {:invalid, [unique: "my_model_foo_index"]})
      |> EctoOne.Changeset.change(x: "foo")
      |> EctoOne.Changeset.put_embed(:embed, embed)
      |> EctoOne.Changeset.unique_constraint(:foo)
    assert {:error, changeset} = TestRepo.update(changeset)
    assert_received {:rollback, ^changeset}
    refute changeset.model.embed
    assert changeset.changes.embed
    refute changeset.changes.embed.model.id
    refute changeset.valid?
  end

  test "handles nested embeds on update" do
    embed = %MyEmbed{id: @uuid, x: "xyz"}
    embed_changeset =
      embed
      |> EctoOne.Changeset.change
      |> EctoOne.Changeset.put_embed(:sub_embed, %SubEmbed{y: "xyz"})
    changeset =
      %MyModel{id: 1, embed: embed}
      |> EctoOne.Changeset.change
      |> EctoOne.Changeset.put_embed(:embed, embed_changeset)
    model = TestRepo.update!(changeset)
    assert model.embed.sub_embed.id
  end

  ## delete

  test "embeds are not removed on delete" do
    embed = %MyEmbed{id: @uuid, x: "xyz"}

    model = TestRepo.delete!(%MyModel{id: 1, embed: embed})
    assert model.embed == embed

    model = TestRepo.delete!(%MyModel{id: 1, embeds: [embed]})
    assert model.embeds == [embed]
  end
end
