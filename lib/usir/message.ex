defmodule Usir.Message do
  alias __MODULE__.{Client,Server}

  @type message :: Client.message | Server.message

  def messages do
    Client.messages ++ Server.messages
  end
end
