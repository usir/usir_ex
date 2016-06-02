defprotocol Usir.Queue do
  def push(queue, job)
  def pop(queue, pending_count \\ 0)
end
