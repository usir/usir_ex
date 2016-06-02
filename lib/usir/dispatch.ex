defprotocol Usir.Dispatch do
  def init(dispatch)
  def call(dispatch, fun)
  def handle_info(dispatch, message)
  def size(dispatch)
end
