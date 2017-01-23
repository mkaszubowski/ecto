defmodule EctoOne.Integration.Schema do
  defmacro __using__(_) do
    quote do
      use EctoOne.Schema

      type =
        Application.get_env(:ecto_one, :primary_key_type) ||
        raise ":primary_key_type not set in :ecto_one application"
      @primary_key {:id, type, autogenerate: true}
      @foreign_key_type type
    end
  end
end

defmodule EctoOne.Integration.Post do
  @moduledoc """
  This module is used to test:

    * Overall functionality
    * Overall types
    * Non-null timestamps
    * Relationships
    * Dependent callbacks

  """
  use EctoOne.Integration.Schema
  import EctoOne.Changeset

  schema "posts" do
    field :counter, :id # Same as integer
    field :title, :string
    field :text, :binary
    field :temp, :string, default: "temp", virtual: true
    field :public, :boolean, default: true
    field :cost, :decimal
    field :visits, :integer
    field :intensity, :float
    field :bid, :binary_id
    field :uuid, EctoOne.UUID, autogenerate: true
    field :meta, :map
    field :posted, EctoOne.Date
    has_many :comments, EctoOne.Integration.Comment, on_delete: :delete_all, on_replace: :delete
    has_one :permalink, EctoOne.Integration.Permalink, on_delete: :fetch_and_delete, on_replace: :delete
    has_many :comments_authors, through: [:comments, :author]
    belongs_to :author, EctoOne.Integration.User
    timestamps
  end

  def changeset(model, params) do
    cast(model, params, [], ~w(counter title text temp public cost visits
                               intensity bid uuid meta posted))
  end
end

defmodule EctoOne.Integration.PostUsecTimestamps do
  @moduledoc """
  This module is used to test:

    * Usec timestamps

  """
  use EctoOne.Integration.Schema

  schema "posts" do
    field :title, :string
    timestamps usec: true
  end
end

defmodule EctoOne.Integration.Comment do
  @moduledoc """
  This module is used to test:

    * Optimistic lock
    * Relationships
    * Dependent callbacks

  """
  use EctoOne.Integration.Schema

  schema "comments" do
    field :text, :string
    field :lock_version, :integer, default: 1
    belongs_to :post, EctoOne.Integration.Post
    belongs_to :author, EctoOne.Integration.User
    has_one :post_permalink, through: [:post, :permalink]
  end
end

defmodule EctoOne.Integration.Permalink do
  @moduledoc """
  This module is used to test:

    * Relationships
    * Dependent callbacks

  """
  use EctoOne.Integration.Schema

  schema "permalinks" do
    field :url, :string
    belongs_to :post, EctoOne.Integration.Post
    belongs_to :user, EctoOne.Integration.User
    has_many :post_comments_authors, through: [:post, :comments_authors]
  end
end

defmodule EctoOne.Integration.User do
  @moduledoc """
  This module is used to test:

    * Timestamps
    * Relationships
    * Dependent callbacks

  """
  use EctoOne.Integration.Schema

  schema "users" do
    field :name, :string
    has_many :comments, EctoOne.Integration.Comment, foreign_key: :author_id, on_delete: :nilify_all
    has_many :posts, EctoOne.Integration.Post, foreign_key: :author_id, on_delete: :nothing, on_replace: :delete
    has_many :permalinks, EctoOne.Integration.Permalink
    belongs_to :custom, EctoOne.Integration.Custom, references: :bid, type: :binary_id
    timestamps
  end
end

defmodule EctoOne.Integration.Custom do
  @moduledoc """
  This module is used to test:

    * binary_id primary key
    * Tying another schemas to an existing model

  Due to the second item, it must be a subset of posts.
  """
  use EctoOne.Integration.Schema

  @primary_key {:bid, :binary_id, autogenerate: true}
  schema "customs" do
    field :uuid, EctoOne.UUID
  end
end

defmodule EctoOne.Integration.Barebone do
  @moduledoc """
  This module is used to test:

    * A model wthout primary keys

  """
  use EctoOne.Integration.Schema

  @primary_key false
  schema "barebones" do
    field :num, :integer
  end
end

defmodule EctoOne.Integration.Tag do
  @moduledoc """
  This module is used to test:

    * The array type
    * Embedding many models (uses array)

  """
  use EctoOne.Integration.Schema

  schema "tags" do
    field :ints, {:array, :integer}
    field :uuids, {:array, EctoOne.UUID}
    embeds_many :items, EctoOne.Integration.Item
  end
end

defmodule EctoOne.Integration.Item do
  @moduledoc """
  This module is used to test:

    * Embedding

  """
  use EctoOne.Integration.Schema

  embedded_schema do
    field :price, :integer
    field :valid_at, EctoOne.Date
  end
end

defmodule EctoOne.Integration.Order do
  @moduledoc """
  This module is used to test:

    * Embedding one model

  """
  use EctoOne.Integration.Schema

  schema "orders" do
    embeds_one :item, EctoOne.Integration.Item
  end
end
