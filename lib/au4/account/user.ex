defmodule Au4.Account.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Inspect, except: [:hashed_password]}
  @derive {Jason.Encoder, except: [:hashed_password]}

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :current_password, :string, virtual: true, redact: true
    field :confirmed_at, :utc_datetime
    field :first_name, :string
    field :middle_name, :string
    field :last_name, :string
    field :idno, :string
    field :phone_number, :string
    field :gender, :string

    many_to_many :apartments, Au4.Context.Apartment, join_through: Au4.Context.UserApartment, on_replace: :delete
    has_many :user_apartments, Au4.Context.UserApartment, on_replace: :delete
    many_to_many :roles, Au4.Access.Role, join_through: Au4.Access.RoleUser, on_replace: :delete
    has_many :permissions, through: [:roles, :permissions]

    timestamps(type: :utc_datetime)
  end

  @spec registration_changeset(
          {map(),
           %{
             optional(atom()) =>
               atom()
               | {:array | :assoc | :embed | :in | :map | :parameterized | :supertype | :try,
                  any()}
           }}
          | %{
              :__struct__ => atom() | %{:__changeset__ => any(), optional(any()) => any()},
              optional(atom()) => any()
            },
          :invalid | %{optional(:__struct__) => none(), optional(atom() | binary()) => any()}
        ) :: Ecto.Changeset.t()
  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.

    * `:validate_email` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ [], apartments \\ [], roles \\ []) do
    user
    |> cast(attrs, [:email, :password, :first_name, :middle_name, :last_name, :idno, :phone_number, :gender])
    |> validate_email(opts)
    |> validate_password(opts)
    |> validate_other_fields()
    |> put_assoc(:apartments, apartments)
    |> put_assoc(:roles, roles)

  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp validate_other_fields(changeset) do
    changeset
    |> validate_required([:first_name, :middle_name, :last_name, :idno, :phone_number, :gender])
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    # Examples of additional password validation:
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # Hashing could be done with `Ecto.Changeset.prepare_changes/2`, but that
      # would keep the database transaction open longer and hurt performance.
      |> put_change(:hashed_password, Pbkdf2.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, Au4.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Pbkdf2.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%Au4.Account.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Pbkdf2.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Pbkdf2.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    changeset = cast(changeset, %{current_password: password}, [:current_password])

    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end

 def has_role?(user, role_name) do
  # 1. Check Global roles (if loaded)
  global_role? =
    if Ecto.assoc_loaded?(user.roles),
      do: Enum.any?(user.roles, &(&1.name == role_name)),
      else: false

  # 2. Check Apartment roles (if loaded)
  apartment_role? =
    if Ecto.assoc_loaded?(user.user_apartments),
      do: Enum.any?(user.user_apartments, fn ua ->
        Ecto.assoc_loaded?(ua.role) && ua.role && ua.role.name == role_name
      end),
      else: false

  global_role? || apartment_role?
end

def has_permission_preloaded?(user, permission_name) do
  if Ecto.assoc_loaded?(user.roles) do
    user.roles
    |> Enum.flat_map(fn role ->
      if Ecto.assoc_loaded?(role.permissions), do: role.permissions, else: []
    end)
    |> Enum.any?(&(&1.name == permission_name))
  else
    # Fallback to a database query if not preloaded
    has_permission?(user.id, permission_name)
  end
end

def has_permission?(%Au4.Account.User{id: id}, permission_name) do
  has_permission?(id, permission_name)
end

def has_permission?(user_id, permission_name) do
  import Ecto.Query

  # Query for Global Permissions
  global_query = from p in Au4.Access.Permission,
    join: r in assoc(p, :roles),
    join: u in assoc(r, :users),
    where: u.id == ^user_id and p.name == ^permission_name,
    select: p.id

  # Query for Apartment-based Permissions
  contextual_query = from p in Au4.Access.Permission,
    join: r in assoc(p, :roles),
    join: ua in Au4.Context.UserApartment, on: ua.role_id == r.id,
    where: ua.user_id == ^user_id and p.name == ^permission_name,
    select: p.id

  # Combine them with union to see if any exist
  full_query = from q in global_query, union: ^contextual_query

  Au4.Repo.all(full_query) |> Enum.any?()
end

@doc """
Checks if a user is associated with a specific apartment.
Accepts either a user struct or a user_id.
"""
def has_apartment?(%Au4.Account.User{id: id}, apartment_id), do: has_apartment?(id, apartment_id)

def has_apartment?(user_id, apartment_id) when is_integer(user_id) do
  import Ecto.Query

  query = from ua in Au4.Context.UserApartment,
    where: ua.user_id == ^user_id and ua.apartment_id == ^apartment_id,
    select: count(ua.id)

  Au4.Repo.one(query) > 0
end

@doc """
Checks for apartment association using preloaded data to avoid DB hits.
"""
def has_apartment_preloaded?(user, apartment_id) do
  if Ecto.assoc_loaded?(user.user_apartments) do
    Enum.any?(user.user_apartments, &(&1.apartment_id == apartment_id))
  else
    has_apartment?(user.id, apartment_id)
  end
end
end
