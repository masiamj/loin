import Config

appsignal_push_api_key = System.get_env("APPSIGNAL_PUSH_API_KEY")

config :appsignal, :config,
  otp_app: :loin,
  name: "loin",
  push_api_key: appsignal_push_api_key,
  env: Mix.env()
