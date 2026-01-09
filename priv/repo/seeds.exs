# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Au4.Repo.insert!(%Au4.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Au4.Repo.insert!(%Au4.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Au4.Repo
alias Au4.Access.Permission

# 1. Path to your JSON file
path = Application.app_dir(:au4, "priv/permission.json")

# 2. Read and Parse JSON
permissions_data =
  path
  |> File.read!()
  |> Jason.decode!()

IO.puts "Seeding permissions..."

# 3. Loop and Insert
for item <- permissions_data do
  # We use Repo.insert directly or Access.create_permission
  # on_conflict: :nothing ensures we don't get duplicate errors on 'name'
  %Permission{}
  |> Permission.changeset(item)
  |> Repo.insert!(
    on_conflict: :nothing,
    conflict_target: :name
  )
end

IO.puts "Permissions seeded successfully!"
