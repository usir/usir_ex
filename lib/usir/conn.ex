defprotocol Usir.Conn do
  Kernel.defstruct format: nil,
                   backend: nil,
                   handler: nil
  alias Usir.Format

  Kernel.def new(backend, handler, format) do
    %__MODULE__{
      backend: backend,
      handler: handler,
      format: format
    }
  end

  Kernel.def encode_packet(%{format: format}, messages) do
    {Format.message_type(format), Format.encode(format, messages)}
  end

  Kernel.def decode_packet(conn = %{format: format, backend: backend, handler: handler}, packet, queue) do
    {backend, queue} = format
    |> Format.decode(packet)
    |> Enum.reduce({backend, queue}, fn(message, {backend, queue}) ->
      handle_message(backend, handler, message, queue)
    end)

    {%{conn | backend: backend}, queue}
  end

  Kernel.def handle_info(conn = %{backend: backend, handler: handler}, message) do
    case handle_info(backend, handler, message) do
      {:error, error, backend} ->
        {:error, error, %{conn | backend: backend}}
      {message, backend} ->
        {message, %{conn | backend: backend}}
    end
  end

  def handle_message(conn, handler, message, queue)
  def handle_info(conn, handler, term)
end
