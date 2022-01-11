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

namespace ygg = yggdrasil_decision_forests;

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

  return enif_make_tuple2(env,
            enif_make_atom(env, "ok"),
            enif_make_resource(env, &model));
}

static ERL_NIF_TERM predict(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM predict_csv(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  return enif_make_atom(env, "ok");
}

static ErlNifFunc nif_funcs[] = {
  {"train", 2, train},
  {"train_csv", 2, train_csv},
  {"predict", 2, predict},
  {"predict_csv", 2, predict_csv},
};

ERL_NIF_INIT(Elixir.Scitree.Native, nif_funcs, NULL, NULL, NULL, NULL)
