#ifndef SCITREE_REPORT
#define SCITREE_REPORT

#include "./scitree_nif_helper.hpp"
#include "yggdrasil_decision_forests/metric/metric.h"
#include "yggdrasil_decision_forests/metric/metric.pb.h"
#include "yggdrasil_decision_forests/utils/distribution.h"

#include <string.h>
#include <erl_nif.h>

namespace scitree
{
namespace report
{
namespace ygg = yggdrasil_decision_forests;
namespace metric = yggdrasil_decision_forests::metric;

void prepare(
    ErlNifEnv *env, ERL_NIF_TERM *report, const metric::proto::EvaluationResults* evaluation 
)
{
    int size = 8;
    ERL_NIF_TERM keys[size];
    ERL_NIF_TERM values[size];

    keys[0] = enif_make_atom(env, "accuracy");
    values[0] = enif_make_double(env, metric::Accuracy(*evaluation));

    keys[1] = enif_make_atom(env, "loss");
    values[1] = enif_make_double(env, metric::LogLoss(*evaluation));

    keys[2] = enif_make_atom(env, "error_rate");
    values[2] = enif_make_double(env, metric::ErrorRate(*evaluation));

    // default values
    keys[3] = enif_make_atom(env, "default_accuracy");
    values[3] = enif_make_double(env, metric::DefaultAccuracy(*evaluation));

    keys[4] = enif_make_atom(env, "default_loss");
    values[4] = enif_make_double(env, metric::DefaultLogLoss(*evaluation));

    keys[5] = enif_make_atom(env, "default_error_rate");
    values[5] = enif_make_double(env, metric::DefaultErrorRate(*evaluation));

    keys[6] = enif_make_atom(env, "number_predictions");
    values[6] = enif_make_double(env, evaluation->count_predictions());

    int nuv = evaluation->label_column().categorical().number_of_unique_values();
    ERL_NIF_TERM cols_rep[nuv];
    for (int index = 0; index < nuv; index++) {
	std::string col = ygg::dataset::CategoricalIdxToRepresentation(evaluation->label_column(), index);
	cols_rep[index] = enif_make_string(env, col.c_str(), ERL_NIF_LATIN1);
    }

    keys[7] = enif_make_atom(env, "cols_representation");
    values[7] = enif_make_list_from_array(env, cols_rep, nuv);

    enif_make_map_from_arrays(env, keys, values, size, report);
}

}
}


#endif
