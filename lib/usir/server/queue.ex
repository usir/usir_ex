defprotocol Usir.Server.Queue do
  def push(queue, job)
  def pop(queue)
end

defimpl Usir.Server.Queue, for: List do
  def push(queue, job) do
    queue ++ [job]
  end

  def pop([]) do
    :empty
  end
  def pop([job | queue]) do
    {job, queue}
  end
end
