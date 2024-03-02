defmodule Mmap do
  @on_load :init

  def init do
    filename = :code.priv_dir(:mmap) |> Path.join("mmap")
    :ok = :erlang.load_nif(filename, 0)
  end

  def read(_filename), do: exit(:nif_not_loaded)

  def read!(filename) do
    case read(filename) do
      {:ok, data} ->
        data

      {:error, reason} ->
        raise File.Error, reason: reason, path: filename, action: "read file"
    end
  end
end
