package(
    default_visibility = ["//visibility:public"],
    licenses = ["notice"],
)

cc_binary(
    name = "scitree",
    srcs = [
        "scitree.cpp",
        "scitree_nif_helper.hpp",
        "scitree_dataset.hpp",
        "scitree_learner.hpp"
    ],
    linkopts = ["-shared"],
    copts = [
        "-Iexternal/erlnif",
        "-fPIC",
        "-O3",
        "-Wall",
        "-Wextra",
        "-fpermissive"
    ],
    deps = [
        "@erlnif//:headers",
        "@com_google_absl//absl/flags:flag",
        "@ydf//yggdrasil_decision_forests/dataset:data_spec_cc_proto",
        "@ydf//yggdrasil_decision_forests/utils:filesystem",
        "@ydf//yggdrasil_decision_forests/utils:logging",
        "@ydf//yggdrasil_decision_forests/dataset:all_dataset_formats",
        "@ydf//yggdrasil_decision_forests/dataset:data_spec",
        "@ydf//yggdrasil_decision_forests/dataset:data_spec_inference",
        "@ydf//yggdrasil_decision_forests/dataset:vertical_dataset_io",
        "@ydf//yggdrasil_decision_forests/learner:all_learners",
        "@ydf//yggdrasil_decision_forests/learner:learner_library",
        "@ydf//yggdrasil_decision_forests/metric",
        "@ydf//yggdrasil_decision_forests/metric:report",
        "@ydf//yggdrasil_decision_forests/model:model_library",
    ]
)
