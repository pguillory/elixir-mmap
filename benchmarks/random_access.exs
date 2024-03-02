filename = "/tmp/test.dat"

:ok = File.write(filename, String.duplicate(".", 100_000_000))

{:ok, file} = :file.open(filename, [:binary])

{:ok, mmap} = Mmap.read(filename)

Benchee.run(
  %{
    "pread" => fn -> :file.pread(file, :rand.uniform(90_000_000), 10_000) end,
    "binary_part" => fn -> binary_part(mmap, :rand.uniform(90_000_000), 10_000) end
  }
)
