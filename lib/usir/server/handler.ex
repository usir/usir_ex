defprotocol Usir.Server.Handler do
  def authenticate(handler, method, token)
  def resolve(handler, component, state, etag, auth, locales)
  def handle_message(handler, affordance, message)
end
