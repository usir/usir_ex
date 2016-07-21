defmodule Test.Usir.Transport.HTTP.Server do
  use ExUnit.Case
  alias Usir.Format
  alias Usir.Format.MSGPACK
  alias Usir.Message.{Client, Server}
  alias __MODULE__.WS

  test "initializes a websocket connection" do
    create_acceptor()
    |> start(fn(address) ->
      client = WS.connect(address, ["msgpack"])

      [%{body: "Hello, 0!"}] = WS.request(client, [%Client.Mount{path: "/"}])
      [%{body: "Hello, 1!"}] = WS.request(client, [%Client.Mount{path: "/foo"}])
      [%Server.Unmounted{}] = WS.request(client, [%Client.Unmount{path: "/"}])
      [%Server.Unmounted{}] = WS.request(client, [%Client.Unmount{path: "/foo"}])
      [%{body: "Hello, 0!"}] = WS.request(client, [%Client.Mount{path: "/"}])

      WS.close(client)
    end)
  end

  test "handles server errors gracefully" do
    create_acceptor()
    |> start(fn(address) ->
      client = WS.connect(address, ["msgpack"])

      [%Server.Error{info: "error!"}] = WS.request(client, [%Client.Mount{path: "/error"}])

      WS.close(client)
    end)
  end

  defp start(acceptor, protocol_opts \\ %{}, callback) do
    {:ok, ref} = Usir.Transport.HTTP.Server.http(acceptor, protocol_opts, [port: 0])
    {_, port} = :ranch.get_addr(ref)
    address = 'ws://localhost:#{port}'
    callback.(address)
    Usir.Transport.HTTP.Server.shutdown(ref)
  end

  defmodule ServerHandler do
    use Usir.Server.Handler

    def init(_, _) do
      {:ok, 0}
    end

    def mount(_handler, %{path: "/error"}) do
      raise Server.Error, path: "/error", info: "error!"
    end
    def mount(handler, %{path: path}) do
      {:ok, %Server.Mounted{path: path, body: "Hello, #{handler}!"}, handler + 1}
    end

    def unmount(handler, %{path: path}) do
      {:ok, %Server.Unmounted{path: path}, handler - 1}
    end

    def authenticate(handler, %{method: method}) do
      {:ok, [%Server.AuthenticationAcknowledged{method: method}, %Server.Mounted{path: "/authed"}], handler}
    end

    def action(handler, _message) do
      {:noreply, handler}
    end

    def handle_info(handler, _info) do
      {:noreply, handler}
    end

    def handle_error(handler, _kind, error, _stacktrace, _message) do
      {:ok, [error], handler}
    end
  end

  defmodule WS do
    def connect(address, formats) do
      headers = for format <- formats do
        {"sec-websocket-protocol", "usir|" <> format}
      end
      {:ok, _} = :application.ensure_all_started(:websocket_client)
      {:ok, pid} = :websocket_client.start_link(address, __MODULE__, self, [extra_headers: headers])
      pid
    end

    def request(pid, message) do
      send(pid, {:req, message})
      receive do
        {:resp, message} ->
          message
      after
        100 ->
          throw :timeout
      end
    end

    def close(pid) do
      send(pid, :close)
    end

    def init(owner, _req) do
      {:ok, owner}
    end

    def websocket_handle({:binary, messages}, _req, owner) do
      format = MSGPACK
      packet = Format.decode(format, messages)
      send(owner, {:resp, packet})
      {:ok, owner}
    end

    def websocket_info({:req, messages}, _req, owner) do
      format = MSGPACK
      type = Format.message_type(format)
      packet = Format.encode(format, messages) |> IO.iodata_to_binary
      {:reply, {type, packet}, owner}
    end
    def websocket_info(:close, _req, owner) do
      {:close, "", owner}
    end

    def websocket_terminate(_, _, _) do
      :ok
    end
  end

  defp create_acceptor() do
    Usir.Acceptor.new(Usir.Server, %{
      "msgpack" => Usir.Format.MSGPACK,
      "json" => Usir.Format.JSON
    }, ServerHandler)
  end
end
