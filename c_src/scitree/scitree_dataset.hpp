#ifndef SCITREE_DATASET
#define SCITREE_DATASET

#include "./scitree_nif_helper.hpp"

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

static std::unordered_map<std::string, proto::ColumnType>
      const spec_types = {
          {"unknown", proto::ColumnType::UNKNOWN},
          {"numerical", proto::ColumnType::NUMERICAL},
          {"numerical_set", proto::ColumnType::NUMERICAL_SET},
          {"numerical_list", proto::ColumnType::NUMERICAL_LIST},
          {"categorical", proto::ColumnType::CATEGORICAL},
          {"categorical_set", proto::ColumnType::CATEGORICAL_SET},
          {"categorical_list", proto::ColumnType::CATEGORICAL_LIST},
          {"boolean", proto::ColumnType::BOOLEAN},
          {"string", proto::ColumnType::STRING},
          {"discretized_numerical", proto::ColumnType::DISCRETIZED_NUMERICAL},
          {"hash", proto::ColumnType::HASH}
      };

void load_data_spec(
  const proto::DataSpecification* data_spec,
  ErlNifEnv *env, ERL_NIF_TERM* tuple, int size
) {
  data_spec->clear_columns();

  for (size_t i = 0; i < size; i++) {
    std::string name, type;
    int size_dataset = 0;
    ERL_NIF_TERM* tuple_dataset;

    enif_get_tuple(env, tuple[i], &size_dataset, &tuple_dataset);

    scitree::nif::get(env, tuple_dataset[0], name);
    scitree::nif::get_atom(env, tuple_dataset[1], type);

    proto::Column* column;
    column = data_spec->add_columns();
    column->set_name(name);

    auto col_type = spec_types.find(type);
    if (col_type != spec_types.end()) {
      column->set_is_manual_type(true);
      column->set_type(col_type->second);
    } else {
      // column->set_is_manual_type(false);
      // detect type or break execution
    }
  }

  // Sort the column by name.
  std::sort(data_spec->mutable_columns()->begin(),
            data_spec->mutable_columns()->end(),
            [](const proto::Column& a, const proto::Column& b) {
              return a.name() < b.name();
            });
}

void load_dataset(
  ds::VerticalDataset *dataset,
  proto::DataSpecification* data_spec,
  ErlNifEnv *env, ERL_NIF_TERM* tuple, int column_size
) {
    dataset->set_data_spec(*data_spec);
    dataset->CreateColumnsFromDataspec();

    int rec_count = 0;
    for (size_t i = 0; i < column_size; i++) {
      rec_count = 0;
      std::string name, type;
      int size_dataset = 0;
      ERL_NIF_TERM* tuple_dataset;

      enif_get_tuple(env, tuple[i], &size_dataset, &tuple_dataset);
      scitree::nif::get(env, tuple_dataset[0], name);
      scitree::nif::get_atom(env, tuple_dataset[1], type);

      const int col_idx = ds::GetColumnIdxFromName(name, *data_spec);

      // put itens in dataset
      int empty = 0;
      ERL_NIF_TERM head, tail;
      ERL_NIF_TERM term = tuple_dataset[2];

      auto col_type = spec_types.find(type);
      if (col_type == spec_types.end()) {
        // return with error
      }

      int idx_type = col_type->second;

      while (!empty) {
        empty = !enif_get_list_cell(env, term, &head, &tail);

        if (!empty) {
          rec_count ++;

          if (idx_type == proto::ColumnType::NUMERICAL) {
            float value;
            scitree::nif::get(env, head, &value);
            auto* col =
              dataset->MutableColumnWithCast<ds::VerticalDataset::NumericalColumn>(col_idx);
            col->Add(value);
          } else if (idx_type == proto::ColumnType::CATEGORICAL) {
            int32_t value;
            scitree::nif::get(env, head, &value);
            auto* col =
              dataset->MutableColumnWithCast<ds::VerticalDataset::CategoricalColumn>(col_idx);
            col->Add(value);
          } else if (idx_type == proto::ColumnType::DISCRETIZED_NUMERICAL) {
            int16_t value;
            scitree::nif::get(env, head, &value);
            auto* col =
              dataset->MutableColumnWithCast<ds::VerticalDataset::DiscretizedNumericalColumn>(col_idx);
            col->Add(value);
          } else if (idx_type == proto::ColumnType::HASH) {
            int64_t value;
            scitree::nif::get(env, head, &value);
            auto* col =
              dataset->MutableColumnWithCast<ds::VerticalDataset::HashColumn>(col_idx);
            col->Add(value);
          } else if (idx_type == proto::ColumnType::STRING) {
            std::string value;
            scitree::nif::get(env, head, value);
            auto* col =
              dataset->MutableColumnWithCast<ds::VerticalDataset::StringColumn>(col_idx);
            col->Add(value);            
          }

          term = tail;
        }
      }
    }
    dataset->set_nrow(rec_count);

}

}
}

#endif
