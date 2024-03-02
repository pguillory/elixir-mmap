# Mmap

This library allows you to mmap a file to an Elixir binary resource. It
provides the same interface as File.read/1 (or File.read!/1) in the Elixir
standard library. The value it returns looks like a regular binary, and you
can treat it like a regular binary (using the String module for example).
However unlike normal binaries, which are immutable in Elixir, it is actually
using mmap to present a live view of the contents of the file.

    :ok = File.write!("file.txt", "hello")
    contents = Mmap.read!("file.txt")
    assert contents == "hello"
    :ok = File.write!("file.txt", "world")
    assert contents == "world"

## Installation

```elixir
def deps do
  [
    {:mmap, "~> 0.1.0"}
  ]
end
```
