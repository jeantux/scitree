#include "absl/flags/flag.h"
#include "yggdrasil_decision_forests/utils/filesystem.h"
#include "yggdrasil_decision_forests/dataset/data_spec.pb.h"
#include "yggdrasil_decision_forests/utils/logging.h"
#include "yggdrasil_decision_forests/dataset/data_spec.h"
#include "yggdrasil_decision_forests/dataset/data_spec_inference.h"
#include "yggdrasil_decision_forests/dataset/vertical_dataset_io.h"
#include "yggdrasil_decision_forests/learner/learner_library.h"
#include "yggdrasil_decision_forests/metric/metric.h"
#include "yggdrasil_decision_forests/metric/report.h"
#include "yggdrasil_decision_forests/model/model_library.h"

#include <map>
#include <vector>
#include <cstring>
#include <erl_nif.h>

#define MAXBUFLEN 1024

namespace ygg = yggdrasil_decision_forests;

static ERL_NIF_TERM train(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  return enif_make_string(env, "example", ERL_NIF_LATIN1);
}


static ERL_NIF_TERM predict(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  return enif_make_string(env, "example", ERL_NIF_LATIN1);
}

static ErlNifFunc nif_funcs[] = {
  {"train", 2, train},
  {"predict", 2, predict},
};

ERL_NIF_INIT(Elixir.Scitree.Native, nif_funcs, NULL, NULL, NULL, NULL)
