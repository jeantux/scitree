#include <erl_nif.h>
#include <string>
#include <iostream>
#include <algorithm>

namespace scitree
{
    namespace nif
    {
        struct SCITREE_ERROR {
            bool error = false;
            std::string reason = "";
        };

        struct SCITREE_CONFIG {
            SCITREE_ERROR error;
            std::string label;
            std::string learner;
            std::string log_directory;
            std::string task;
        };

        ERL_NIF_TERM ok(ErlNifEnv* env) {
            return enif_make_atom(env, "ok");
        }

        ERL_NIF_TERM error(ErlNifEnv* env, const char* msg) {
            ERL_NIF_TERM atom = enif_make_atom(env, "error");
            ERL_NIF_TERM msg_term = enif_make_string(env, msg, ERL_NIF_LATIN1);
            return enif_make_tuple2(env, atom, msg_term);
        }


        // string
        int get(ErlNifEnv* env, ERL_NIF_TERM term, std::string &var) {
            unsigned len;
            int ret = enif_get_list_length(env, term, &len);

            if (!ret) {
            ErlNifBinary bin;
            ret = enif_inspect_binary(env, term, &bin);
            if (!ret) {
                return 0;
            }
            var = std::string((const char*)bin.data, bin.size);
            return ret;
            }

            var.resize(len+1);
            ret = enif_get_string(env, term, &*(var.begin()), var.size(), ERL_NIF_LATIN1);

            if (ret > 0) {
            var.resize(ret-1);
            } else if (ret == 0) {
            var.resize(0);
            } else {}

            return ret;
        }

        int get_atom(ErlNifEnv* env, ERL_NIF_TERM term, std::string &var) {
            unsigned atom_length;
            if (!enif_get_atom_length(env, term, &atom_length, ERL_NIF_LATIN1)) {
            return 0;
            }

            var.resize(atom_length+1);

            if (!enif_get_atom(env, term, &(*(var.begin())), var.size(), ERL_NIF_LATIN1)) return 0;

            var.resize(atom_length);

            return 1;
        }

        ERL_NIF_TERM atom(ErlNifEnv* env, const char* msg) {
            return enif_make_atom(env, msg);
        }

        SCITREE_CONFIG make_scitree_config(ErlNifEnv* env, ERL_NIF_TERM term) {
            SCITREE_CONFIG config;

            ERL_NIF_TERM label_nif, learner_nif, log_directory_nif, task_nif;
            std::string label, learner, log_directory, task;
            
            enif_get_map_value(env, term, enif_make_atom(env, "label"), &label_nif);
            enif_get_map_value(env, term, enif_make_atom(env, "learner"), &learner_nif);
            enif_get_map_value(env, term, enif_make_atom(env, "log_directory"), &log_directory_nif);
            enif_get_map_value(env, term, enif_make_atom(env, "task"), &task_nif);


            if (!get(env, label_nif, label)) {
                config.error.error = true;
                config.error.reason = "Unable to get label.";

                return config;
            }

            if (!get_atom(env, learner_nif, learner)) {
                config.error.error = true;
                config.error.reason = "Unable to get learner.";

                return config;
            }

            if (!get(env, log_directory_nif, log_directory)) {
                config.error.error = true;
                config.error.reason = "Unable to get log_directory.";

                return config;
            }

            if (!get_atom(env, task_nif, task)) {
                config.error.error = true;
                config.error.reason = "Unable to get task.";

                return config;
            }

            std::transform(learner.begin(), learner.end(), learner.begin(), ::toupper);

            config.label = label;
            config.learner = learner;
            config.log_directory = log_directory;
            config.task = task;

            return config;
        }
    }
}