#ifndef SCITREE_NIF_HELPER
#define SCITREE_NIF_HELPER

#include <erl_nif.h>
#include <string>
#include <iostream>
#include <algorithm>
#include "yggdrasil_decision_forests/model/abstract_model.pb.h"

namespace scitree
{
namespace nif
{
namespace ygg = yggdrasil_decision_forests;
using real = double;

struct SCITREE_ERROR {
    bool status = false;
    std::string reason = "";
};

struct SCITREE_OPTIONS {
    real maximum_training_duration_seconds;
    real maximum_model_size_in_memory_in_bytes;
    int random_seed;
};

struct SCITREE_CONFIG {
    SCITREE_ERROR error;
    std::string label;
    std::string learner;
    std::string log_directory;
    ygg::model::proto::Task task;
    SCITREE_OPTIONS options;
};

ERL_NIF_TERM ok(ErlNifEnv *env) {
    return enif_make_atom(env, "ok");
}

ERL_NIF_TERM error(ErlNifEnv *env, const char *msg) {
    ERL_NIF_TERM atom = enif_make_atom(env, "error");
    ERL_NIF_TERM msg_term = enif_make_string(env, msg, ERL_NIF_LATIN1);
    return enif_make_tuple2(env, atom, msg_term);
}

// string
int get(ErlNifEnv *env, ERL_NIF_TERM term, std::string &var) {
    unsigned len;
    int ret = enif_get_list_length(env, term, &len);

    if (!ret) {
        ErlNifBinary bin;
        ret = enif_inspect_binary(env, term, &bin);
        if (!ret)
            return 0;
        var = std::string((const char *)bin.data, bin.size);
        return ret;
    }

    var.resize(len + 1);
    ret = enif_get_string(env, term, &*(var.begin()), var.size(), ERL_NIF_LATIN1);

    if (ret > 0) {
        var.resize(ret - 1);
    }
    else if (ret == 0) {
        var.resize(0);
    }

    return ret;
}

// Numeric types
int get(ErlNifEnv *env, ERL_NIF_TERM term, int *var) {
    int value;
    if (!enif_get_int(env, term, &value))
        return 0;
    *var = static_cast<int>(value);
    return 1;
}

int get(ErlNifEnv *env, ERL_NIF_TERM term, int16_t *var) {
    int value;
    if (!enif_get_int(env, term, &value))
        return 0;
    *var = static_cast<int16_t>(value);
    return 1;
}

int get(ErlNifEnv *env, ERL_NIF_TERM term, int64_t *var) {
    int value;
    if (!enif_get_int(env, term, &value))
        return 0;
    *var = static_cast<int64_t>(value);
    return 1;
}

int get(ErlNifEnv *env, ERL_NIF_TERM term, float *var) {
    double value;
    if (!enif_get_double(env, term, &value))
        return 0;
    *var = static_cast<float>(value);
    return 1;
}

int get(ErlNifEnv *env, ERL_NIF_TERM term, real *var) {
    enif_get_double(env, term, var);
    return 0;
}

// atom's
int get_atom(ErlNifEnv *env, ERL_NIF_TERM term, std::string &var) {
    unsigned atom_length;
    if (!enif_get_atom_length(env, term, &atom_length, ERL_NIF_LATIN1)) {
        return 0;
    }

    var.resize(atom_length + 1);

    if (!enif_get_atom(env, term, &(*(var.begin())), var.size(), ERL_NIF_LATIN1))
        return 0;

    var.resize(atom_length);

    return 1;
}

// scitree types
SCITREE_CONFIG make_scitree_config(ErlNifEnv *env, ERL_NIF_TERM term) {
    SCITREE_CONFIG config;

    ERL_NIF_TERM label_nif, learner_nif, log_directory_nif, task_nif, options_nif;
    std::string label, learner, log_directory, task_str;

    enif_get_map_value(env, term, enif_make_atom(env, "label"), &label_nif);
    enif_get_map_value(env, term, enif_make_atom(env, "learner"), &learner_nif);
    enif_get_map_value(env, term, enif_make_atom(env, "log_directory"), &log_directory_nif);
    enif_get_map_value(env, term, enif_make_atom(env, "task"), &task_nif);
    enif_get_map_value(env, term, enif_make_atom(env, "options"), &options_nif);

    if (!get(env, label_nif, label)) {
        config.error.status = true;
        config.error.reason = "Unable to get label.";

        return config;
    }

    if (!get_atom(env, learner_nif, learner)) {
        config.error.status = true;
        config.error.reason = "Unable to get learner.";

        return config;
    }

    if (!get(env, log_directory_nif, log_directory)) {
        config.error.status = true;
        config.error.reason = "Unable to get log_directory.";

        return config;
    }

    if (!get_atom(env, task_nif, task_str)) {
        config.error.status = true;
        config.error.reason = "Unable to get task.";

        return config;
    }

    std::transform(learner.begin(), learner.end(), learner.begin(), ::toupper);
    std::transform(task_str.begin(), task_str.end(), task_str.begin(), ::toupper);

    if (task_str == "CLASSIFICATION") {
        config.task = ygg::model::proto::Task::CLASSIFICATION;
    } else if (task_str == "REGRESSION") {
        config.task = ygg::model::proto::Task::REGRESSION;
    } else if (task_str == "RANKING") {
        config.task = ygg::model::proto::Task::RANKING;
    } else if (task_str == "CATEGORICAL_UPLIFT") {
        config.task = ygg::model::proto::Task::CATEGORICAL_UPLIFT;
    } else {
        config.task = ygg::model::proto::Task::UNDEFINED;
    }

    ERL_NIF_TERM max_train_sec_nif, max_model_size_nif, random_seed_nif;

    enif_get_map_value(env, options_nif, enif_make_atom(env, "maximum_training_duration_seconds"), &max_train_sec_nif);
    enif_get_map_value(env, options_nif, enif_make_atom(env, "maximum_model_size_in_memory_in_bytes"), &max_model_size_nif);
    enif_get_map_value(env, options_nif, enif_make_atom(env, "random_seed"), &random_seed_nif);

    get(env, max_train_sec_nif, &config.options.maximum_training_duration_seconds);
    get(env, max_model_size_nif, &config.options.maximum_model_size_in_memory_in_bytes);
    get(env, random_seed_nif, &config.options.random_seed);

    config.label = label;
    config.learner = learner;
    config.log_directory = log_directory;

    return config;
}

}

}

#endif
