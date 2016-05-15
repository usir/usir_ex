defprotocol Usir.Server.Queue do
  def push(queue, job)
  def pop(queue, pending_count \\ 0)
end

defimpl Usir.Server.Queue, for: List do
  def push(queue, job) do
    queue ++ [job]
  end

  def pop([job | queue], pending_count) when pending_count < 10 do
    {job, queue}
  end
  def pop(_, _) do
    :empty
  end
end
