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

There are several potential advantages to using mmap over regular disk reads:

1. Code (like parsers) designed to process data in memory can be used
unmodified to process data on disk.

2. Speed. Grabbing slices of a file using mmap and [Kernel.binary_part] is
often much faster than something like [:file.pread].

3. You can process a large file without reading the entire thing into memory
at once.

[Kernel.binary_part]: https://hexdocs.pm/elixir/Kernel.html#binary_part/3
[:file.pread]: https://www.erlang.org/doc/man/file#pread-3

Under the hood, the file handle is held open until the binary resource is
garbage collected, at which point it is automatically munmap-ed and closed.

Note that this is a read-only view of the file. It's simply a result of the
choice to represent the file contents as a binary. Elixir/Erlang have no
functionality for writing to a binary, because they are typically immutable.

## Installation

```elixir
def deps do
  [
    {:mmap, "~> 0.1.0"}
  ]
end
```
