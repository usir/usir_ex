defmodule Usir.Queue.ErlQueue do
  defstruct queue: :queue.new(),
            limit: 10
end

defimpl Usir.Queue, for: Usir.Queue.ErlQueue do
  def push(%{queue: q} = queue, job) do
    %{queue | queue: :queue.in(job, q)}
  end

  def pop(%{limit: limit, queue: q} = queue, pending) when pending < limit do
    case :queue.out(q) do
      {:empty, _} ->
        :empty
      {{:value, job}, q} ->
        {job, %{queue | queue: q}}
    end
  end
end
