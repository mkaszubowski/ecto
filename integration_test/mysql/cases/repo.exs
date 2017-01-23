defmodule EctoOne.Integration.RepoTest do
  use EctoOne.Integration.Case

  alias EctoOne.Integration.TestRepo
  import EctoOne.Query


  test "insert and update with changeset read after writes on a non pk auto increment field" do
    defmodule RAW do
      use EctoOne.Schema

      @primary_key {:id, :integer, autogenerate: false}
      schema "mysql_raw_on_non_pk" do
        field :non_pk_auto_increment_id, :id, read_after_writes: true
      end
    end

    changeset = EctoOne.Changeset.cast(struct(RAW, %{id: 1}), %{}, ~w(), ~w())
    %{non_pk_auto_increment_id: cid} = TestRepo.insert!(changeset)

    assert cid != nil
  end
end
