.PHONY: nifs clean publish

ERL_PATH = $(shell elixir -e 'IO.puts [:code.root_dir, "/erts-", :erlang.system_info :version]')
CFLAGS := -fPIC -I $(ERL_PATH)/include

UNAME_SYS := $(shell uname -s)
ifeq ($(UNAME_SYS), Darwin)
	CFLAGS += -bundle -bundle_loader $(ERL_PATH)/bin/beam.smp
else ifeq ($(UNAME_SYS), FreeBSD)
	CFLAGS += -shared
else ifeq ($(UNAME_SYS), Linux)
	CFLAGS += -shared
endif

nifs: priv/mmap.so

test: nifs
	mix test

priv:
	mkdir -p priv

priv/mmap.so: priv src/mmap.c
	gcc -o priv/mmap.so src/mmap.c $(CFLAGS)

clean:
	rm -f priv/mmap.so

publish: clean
	mix hex.publish
