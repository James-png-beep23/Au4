defmodule Au4Web.PageController do
  use Au4Web, :controller
  alias Au4.Access


  def home(conn, _params) do
    # 1. Fetch the roles from your context
    roles = Access.list_roles()

    # 2. Pass them into the render function
    render(conn, :home, roles: roles, layout: false)
  end
end
