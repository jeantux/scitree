#include "./scitree_nif_helper.hpp"
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

ErlNifResourceType* RES_TYPE;

namespace ygg = yggdrasil_decision_forests;

static int open_resource(ErlNifEnv* env)
{
    const char* mod = "resources";
    const char* name = "yggdrasil";
    int flags = ERL_NIF_RT_CREATE | ERL_NIF_RT_TAKEOVER;

    RES_TYPE = enif_open_resource_type(env, mod, name, NULL, (ErlNifResourceFlags) flags, NULL);
    if(RES_TYPE == NULL) return -1;
    return 0;
}

static int load(ErlNifEnv* env, void** priv, ERL_NIF_TERM load_info)
{
    if(open_resource(env) == -1) return -1;

    return 0;
}

static ERL_NIF_TERM train(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM train_csv(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  scitree::nif::SCITREE_CONFIG config = scitree::nif::make_scitree_config(env, argv[0]);

  if (config.error.error) {
    return scitree::nif::error(env, config.error.reason.c_str());
  }

  std::string path;

  if (!scitree::nif::get(env, argv[1], path)) {
      return scitree::nif::error(env, "Unable to get csv path.");
  }

  auto dataset_path = "csv:" + path;
  // Training configuration
  ygg::model::proto::TrainingConfig train_config;
  train_config.set_learner(config.learner);
  train_config.set_task(ygg::model::proto::Task::CLASSIFICATION);
  train_config.set_label(config.label);
  // Scan the dataset
  ygg::dataset::proto::DataSpecification spec;
  ygg::dataset::CreateDataSpec(dataset_path, false, {}, &spec);
  
  // Train a model  
  std::unique_ptr<ygg::model::AbstractLearner> learner;
  GetLearner(train_config, &learner);
  auto model = learner->Train(dataset_path, spec);
  ygg::model::AbstractModel **p_model;
  p_model = (ygg::model::AbstractModel **)enif_alloc_resource(RES_TYPE, sizeof(ygg::model::AbstractModel *));

  *p_model = model.release(); 

  if (*p_model == NULL)
    return scitree::nif::error(env, "Unable to open resource.");

  ERL_NIF_TERM resource = enif_make_resource(env, p_model);

  return enif_make_tuple2(env, scitree::nif::ok(env), resource);
}

static ERL_NIF_TERM predict(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  return scitree::nif::ok(env);
}

static ERL_NIF_TERM predict_csv(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ygg::model::AbstractModel **p_model;

  if (!enif_get_resource(env, argv[0], RES_TYPE, (void**) &p_model)) {
    return scitree::nif::error(env, "Unable to load resource.");
  }

  // ...
  
  return scitree::nif::ok(env);
}

static ErlNifFunc nif_funcs[] = {
  {"train", 2, train},
  {"train_csv", 2, train_csv},
  {"predict", 2, predict},
  {"predict_csv", 2, predict_csv},
};

ERL_NIF_INIT(Elixir.Scitree.Native, nif_funcs, &load, NULL, NULL, NULL)
