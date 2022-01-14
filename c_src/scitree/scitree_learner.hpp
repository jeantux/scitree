#ifndef SCITREE_LEARNER
#define SCITREE_LEARNER

#include "./scitree_nif_helper.hpp"
#include "yggdrasil_decision_forests/learner/learner_library.h"
#include "yggdrasil_decision_forests/learner/decision_tree/generic_parameters.h"

namespace ygg = yggdrasil_decision_forests;
namespace model = yggdrasil_decision_forests::model;

namespace scitree
{
namespace learner
{
// Defines Generic Hyper-parameters settings that 
// will be assigned in yggdrasil learner

model::proto::GenericHyperParameters get_hyper_params(nif::SCITREE_OPTIONS opts) {
    model::proto::GenericHyperParameters hparams;

    auto *max_train_seconds = hparams.add_fields();
    max_train_seconds->set_name(model::kHParamMaximumTrainingDurationSeconds);
    max_train_seconds->mutable_value()->set_real(opts.maximum_training_duration_seconds);

    auto *max_model_mem_size = hparams.add_fields();
    max_model_mem_size->set_name(model::kHParamMaximumModelSizeInMemoryInBytes);
    max_model_mem_size->mutable_value()->set_real(opts.maximum_model_size_in_memory_in_bytes);

    auto *random_seed = hparams.add_fields();
    random_seed->set_name(model::kHParamRandomSeed);
    random_seed->mutable_value()->set_integer(opts.random_seed);

    return hparams;
}
}
}

#endif
