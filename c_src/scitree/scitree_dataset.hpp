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

scitree::nif::SCITREE_ERROR load_data_spec(
  proto::DataSpecification* data_spec,
  ErlNifEnv *env, ERL_NIF_TERM* tuple, int size
) {
  scitree::nif::SCITREE_ERROR error;
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
      column->set_type(col_type->second);
    } else {
      error.status = true;
      error.reason = "type not identified to column " + name;
    }

  }

  std::sort(data_spec->mutable_columns()->begin(),
            data_spec->mutable_columns()->end(),
            [](const proto::Column& a, const proto::Column& b) {
              return a.name() < b.name();
            });

  return error;
}

scitree::nif::SCITREE_ERROR load_dataset(
  ds::VerticalDataset *dataset,
  proto::DataSpecification* data_spec,
  ErlNifEnv *env, ERL_NIF_TERM* tuple, int column_size
) {
  scitree::nif::SCITREE_ERROR error;
  dataset->set_data_spec(*data_spec);
  dataset->CreateColumnsFromDataspec();
  
  // Initialize accumulator
  ds::proto::DataSpecificationAccumulator accumulator;
  ds::InitializeDataspecAccumulator(dataset->data_spec(), &accumulator);
  
  for (int i = 0; i < column_size; i++) {
    std::string name, type;
    int size_dataset = 0;
    ERL_NIF_TERM* tuple_dataset;

    enif_get_tuple(env, tuple[i], &size_dataset, &tuple_dataset);
    scitree::nif::get(env, tuple_dataset[0], name);
    scitree::nif::get_atom(env, tuple_dataset[1], type);
    
    int empty = 0;
    ERL_NIF_TERM head, tail;
    ERL_NIF_TERM term = tuple_dataset[2];

    auto col_type = spec_types.find(type);
    if (col_type == spec_types.end()) {
      error.status = true;
      error.reason = "type not identified to column " + name;
    }

    int idx_type = col_type->second;
    auto* col = dataset->mutable_data_spec()->mutable_columns(i);
    auto* col_acc = accumulator.mutable_columns(i);

    while (!empty) {
      empty = !enif_get_list_cell(env, term, &head, &tail);

      if (!empty) {

        if (idx_type == proto::ColumnType::NUMERICAL) {
          float value;
          scitree::nif::get(env, head, &value);
          ds::UpdateNumericalColumnSpec(value, col, col_acc);
        } else if (idx_type == proto::ColumnType::CATEGORICAL) {
          int32_t value;
          scitree::nif::get(env, head, &value);
          ds::UpdateCategoricalIntColumnSpec(value, col, col_acc);
        }

        term = tail;
      }
    }
  }

  // Add values in dataset
  int rec_count = 0;
  for (int i = 0; i < column_size; i++) {
    rec_count = 0;
    std::string name, type;
    int size_dataset = 0;
    ERL_NIF_TERM* tuple_dataset;

    enif_get_tuple(env, tuple[i], &size_dataset, &tuple_dataset);
    scitree::nif::get(env, tuple_dataset[0], name);
    scitree::nif::get_atom(env, tuple_dataset[1], type);

    int empty = 0;
    ERL_NIF_TERM head, tail;
    ERL_NIF_TERM term = tuple_dataset[2];
    auto col_type = spec_types.find(type);
    if (col_type == spec_types.end()) {
      error.status = true;
      error.reason = "type not identified to column " + name;
    }

    int idx_type = col_type->second;
    
    const int col_idx = ds::GetColumnIdxFromName(name, dataset->data_spec());

    if (idx_type == proto::ColumnType::CATEGORICAL) {
      const auto& col_spec = dataset->data_spec().columns(i);
      auto* col_data = dataset->MutableColumnWithCast<ds::VerticalDataset::CategoricalColumn>(col_idx);
      col_data->Resize(0);

      while (!empty) {
        empty = !enif_get_list_cell(env, term, &head, &tail);

        if (!empty) {
          int32_t value;
          scitree::nif::get(env, head, &value);

          if (value < ds::VerticalDataset::CategoricalColumn::kNaValue) {
            // Treated as missing value.
            value = ds::VerticalDataset::CategoricalColumn::kNaValue;
          }
          if (value >= col_spec.categorical().number_of_unique_values()) {
            // Treated as out-of-dictionary.
            value = 0;
          }
          col_data->Add(value);

          term = tail;
        }
      }
    } else if (idx_type == proto::ColumnType::NUMERICAL) {
      auto* col_num = dataset->MutableColumnWithCast<ds::VerticalDataset::NumericalColumn>(col_idx);

      while (!empty) {
        empty = !enif_get_list_cell(env, term, &head, &tail);

        if (!empty) {
          rec_count ++;

          float value;
          scitree::nif::get(env, head, &value);

          col_num->Add(value);
        }

        term = tail;
      }
    }
  }

  dataset->mutable_data_spec()->set_created_num_rows(rec_count);
  dataset->set_nrow(rec_count);

  return error;
}

}
}

#endif
