defmodule Loin.Accounts.IdentityToken do
  @moduledoc """
  Exposes functions for identities tokens.
  """

  use Ecto.Schema
  import Ecto.Query
  alias Loin.Accounts.IdentityToken

  @rand_size 32

  # It is very important to keep the reset password token expiry short,
  # since someone with access to the email may take over the account.
  @session_validity_in_days 60

  @timestamps_opts [type: :utc_datetime_usec]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "identities_tokens" do
    field :token, :binary
    belongs_to :identity, Loin.Accounts.Identity

    timestamps(updated_at: false)
  end

  @doc """
  Generates a token that will be stored in a signed place,
  such as session or cookie. As they are signed, those
  tokens do not need to be hashed.

  The reason why we store session tokens in the database, even
  though Phoenix already provides a session cookie, is because
  Phoenix' default session cookies are not persisted, they are
  simply signed and potentially encrypted. This means they are
  valid indefinitely, unless you change the signing/encryption
  salt.

  Therefore, storing them allows individual identity
  sessions to be expired. The token system can also be extended
  to store additional data, such as the device used for logging in.
  You could then use this information to display all valid sessions
  and devices in the UI and allow users to explicitly expire any
  session they deem invalid.
  """
  def build_session_token(identity) do
    token = :crypto.strong_rand_bytes(@rand_size)
    {token, %IdentityToken{token: token, identity_id: identity.id}}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the identity found by the token, if any.

  The token is valid if it matches the value in the database and it has
  not expired (after @session_validity_in_days).
  """
  def verify_session_token_query(token) do
    query =
      from identity_token in Identity,
        join: identity in assoc(identity_token, :identity),
        where: identity_token.inserted_at > ago(@session_validity_in_days, "day"),
        where: identity_token.token == ^token,
        select: identity

    {:ok, query}
  end
end
