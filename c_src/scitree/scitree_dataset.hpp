#ifndef SCITREE_DATASET
#define SCITREE_DATASET

#include "yggdrasil_decision_forests/dataset/data_spec.pb.h"
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

namespace scitree
{
namespace dataset
{

namespace ygg = yggdrasil_decision_forests;
namespace ds = yggdrasil_decision_forests::dataset;
namespace proto = yggdrasil_decision_forests::dataset::proto;

ds::VerticalDataset *to_data_set(const proto::DataSpecification &data_spec) {
    ds::VerticalDataset *dataset;
    dataset->set_data_spec(data_spec);

    dataset->CreateColumnsFromDataspec();
    dataset->set_nrow(0);

    // for (const auto* example : list_elixir_dataset) {
    //     dataset->AppendExample(*example, config.load_columns);
    // }

    return dataset;
}

}
}

#endif
