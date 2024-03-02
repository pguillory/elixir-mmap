defmodule MmapTest do
  use ExUnit.Case

  @dir "/tmp/MmapTest"
  @filename "#{@dir}/file.dat"
  @nonexistent_filename "#{@dir}/nonexistent.dat"

  setup do
    File.rm_rf(@dir)
    File.mkdir_p!(@dir)

    on_exit(fn ->
      File.rm_rf(@dir)
    end)
  end

  test "read" do
    :ok = File.write!(@filename, "abcd")
    assert {:ok, mmap} = Mmap.read(@filename)
    assert is_binary(mmap)
    assert mmap == "abcd"
    assert String.slice(mmap, 1, 2) == "bc"

    # Changing the file immediately changes the mmap.
    :ok = File.write!(@filename, "1234")
    assert mmap == "1234"
    assert String.slice(mmap, 1, 2) == "23"
  end

  test "read nonexistent file returns error" do
    assert Mmap.read(@nonexistent_filename) == {:error, :enoent}
  end

  test "read! nonexistent file raises error" do
    assert catch_error(Mmap.read!(@nonexistent_filename)) == %File.Error{
             reason: :enoent,
             path: @nonexistent_filename,
             action: "read file"
           }

    # Same error as File.read!/1 raises.
    assert catch_error(File.read!(@nonexistent_filename)) == %File.Error{
             reason: :enoent,
             path: @nonexistent_filename,
             action: "read file"
           }
  end

  test "read rejects long filenames" do
    long_filename = String.duplicate("a", 1000)

    assert catch_error(Mmap.read!(long_filename)) |> Exception.message() ==
             "could not read file #{inspect(long_filename)}: file name too long"
  end
end
