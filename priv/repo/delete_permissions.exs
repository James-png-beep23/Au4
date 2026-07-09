alias Au4.Repo
alias Au4.Access.Permission

import Ecto.Query

permission_names = [
  "view dashboard",
  "manage users",
  "create user",
  "create roles",
  "assign permissions",
  "assign roles",
  "edit roles"
]

from(p in Permission, where: p.name in ^permission_names)
|> Repo.delete_all()

IO.puts("Permissions deleted successfully!")
