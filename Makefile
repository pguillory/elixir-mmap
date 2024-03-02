.PHONY: nifs clean

ERL_PATH = $(shell elixir -e 'IO.puts [:code.root_dir, "/erts-", :erlang.system_info :version]')

nifs: priv/mmap.so

test: nifs
	mix test

priv:
	mkdir -p priv

priv/mmap.so: priv src/mmap.c
	gcc -fPIC -o priv/mmap.so src/mmap.c -I $(ERL_PATH)/include -bundle -bundle_loader $(ERL_PATH)/bin/beam.smp

clean:
	rm -f priv/mmap.so
