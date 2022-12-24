defmodule Loin.Mailer do
  @moduledoc """
  Initializes the Mailer providers for the application.
  """

  use Swoosh.Mailer, otp_app: :loin
end
