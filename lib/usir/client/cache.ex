defprotocol Usir.Client.Cache do
  def get(cache, path)
  def get_info(cache, path)
  def put(cache, path, info, data)
  def delete(cache, path)
end

defimpl Usir.Client.Cache, for: Map do
  def get(cache, path) do
    Map.get(cache, {:data, path})
  end

  def get_info(cache, path) do
    Map.get(cache, {:info, path})
  end

  def put(cache, path, info, data) do
    cache
    |> Map.put({:info, path}, info)
    |> Map.put({:data, path}, data)
  end

  def delete(cache, path) do
    cache
    |> Map.delete({:info, path})
    |> Map.delete({:data, path})
  end
end
