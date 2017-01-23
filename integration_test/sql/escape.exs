defmodule EctoOne.Integration.EscapeTest do
  use EctoOne.Integration.Case

  alias EctoOne.Integration.TestRepo
  import EctoOne.Query
  alias EctoOne.Integration.Post

  test "Repo.all escape" do
    TestRepo.insert!(%Post{title: "hello"})

    query = from(p in Post, select: "'\\")
    assert ["'\\"] == TestRepo.all(query)
  end

  test "Repo.insert! escape" do
    TestRepo.insert!(%Post{title: "'"})

    query = from(p in Post, select: p.title)
    assert ["'"] == TestRepo.all(query)
  end

  test "Repo.update! escape" do
    p = TestRepo.insert!(%Post{title: "hello"})
    TestRepo.update!(EctoOne.Changeset.change p, title: "'")

    query = from(p in Post, select: p.title)
    assert ["'"] == TestRepo.all(query)
  end

  test "Repo.update_all escape" do
    TestRepo.insert!(%Post{title: "hello"})
    TestRepo.update_all(Post, set: [title: "'"])

    reader = from(p in Post, select: p.title)
    assert ["'"] == TestRepo.all(reader)

    query = from(Post, where: "'" != "")
    TestRepo.update_all(query, set: [title: "''"])

    assert ["''"] == TestRepo.all(reader)
  end

  test "Repo.delete_all escape" do
    TestRepo.insert!(%Post{title: "hello"})
    assert [_] = TestRepo.all(Post)

    TestRepo.delete_all(from(Post, where: "'" == "'"))
    assert [] == TestRepo.all(Post)
  end
end
