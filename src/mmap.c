#include <assert.h>
#include <erl_nif.h>
#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

ERL_NIF_TERM ok_atom;
ERL_NIF_TERM error_atom;

void make_atoms(ErlNifEnv * env) {
  ok_atom = enif_make_atom(env, "ok");
  error_atom = enif_make_atom(env, "error");
}

struct mmap_resource {
  int fd;
  char * data;
  int size;
};

void mmap_resource_destructor(ErlNifEnv* caller_env, void * obj) {
  struct mmap_resource * mmap_resource = obj;
  if (munmap(mmap_resource->data, mmap_resource->size) == -1) {
    // Umm...
  }
  close(mmap_resource->fd);
}

ErlNifResourceType * mmap_resource_type;

void open_mmap_resource(ErlNifEnv * env) {
  ErlNifResourceFlags tried;
  mmap_resource_type = enif_open_resource_type(env, NULL, "mmap", mmap_resource_destructor, ERL_NIF_RT_CREATE, &tried);
}

struct mmap_resource * alloc_mmap_resource() {
  return enif_alloc_resource(mmap_resource_type, sizeof(struct mmap_resource));
}

char * errno_string() {
  switch (errno) {
    case EACCES: return "eacces";
    case EBADF: return "ebadf";
    case EBUSY: return "ebusy";
    case EDQUOT: return "edquot";
    case EEXIST: return "eexist";
    case EFAULT: return "efault";
    case EFBIG: return "efbig";
    case EINTR: return "eintr";
    case EINVAL: return "einval";
    case EISDIR: return "eisdir";
    case ELOOP: return "eloop";
    case EMFILE: return "emfile";
    case ENAMETOOLONG: return "enametoolong";
    case ENFILE: return "enfile";
    case ENODEV: return "enodev";
    case ENOENT: return "enoent";
    case ENOMEM: return "enomem";
    case ENOSPC: return "enospc";
    case ENOTDIR: return "enotdir";
    case ENXIO: return "enxio";
    case EOPNOTSUPP: return "eopnotsupp";
    case EOVERFLOW: return "eoverflow";
    case EPERM: return "eperm";
    case EROFS: return "erofs";
    case ETXTBSY: return "etxtbsy";
    case EWOULDBLOCK: return "ewouldblock";
    default: return "unknown";
  }
}

static ERL_NIF_TERM read_nif(ErlNifEnv * env, int argc, const ERL_NIF_TERM argv[]) {
  ErlNifBinary string_value;

  if (argc != 1 ||
      !enif_inspect_binary(env, argv[0], &string_value)) {
    return enif_make_badarg(env);
  }

  if (string_value.size >= 256) {
    return enif_make_tuple2(env, error_atom, enif_make_atom(env, "enametoolong"));
  }

  char filename[256];
  assert(string_value.size < 256);
  memcpy(filename, string_value.data, string_value.size);
  filename[string_value.size] = 0;

  int fd = open(filename, O_RDONLY);
  if (fd == -1) {
    return enif_make_tuple2(env, error_atom, enif_make_atom(env, errno_string()));
  }

  struct stat st;
  if (stat(filename, &st) == -1) {
    return enif_make_tuple2(env, error_atom, enif_make_atom(env, errno_string()));
  }

  char * data = mmap(0, st.st_size, PROT_READ, MAP_SHARED, fd, 0);
  if (data == MAP_FAILED) {
    return enif_make_tuple2(env, error_atom, enif_make_atom(env, errno_string()));
  }

  struct mmap_resource * mmap_resource = alloc_mmap_resource();
  mmap_resource->fd = fd;
  mmap_resource->data = data;
  mmap_resource->size = st.st_size;

  ERL_NIF_TERM mmap = enif_make_resource_binary(env, mmap_resource, data, st.st_size);
  return enif_make_tuple2(env, ok_atom, mmap);
}

static ErlNifFunc nif_funcs[] = {
  {"read", 1, read_nif},
};

int load(ErlNifEnv * env, void ** priv_data, ERL_NIF_TERM load_info) {
  make_atoms(env);
  open_mmap_resource(env);
  return 0;
}

ERL_NIF_INIT(Elixir.Mmap, nif_funcs, load, NULL, NULL, NULL)
