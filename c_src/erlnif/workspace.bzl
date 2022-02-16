def deps(prefix = ""):
    build_file_content = """
package(default_visibility = ["//visibility:public"])
cc_library(
    name = "headers",
    hdrs = glob(["**/*.h"])
)
  """

    native.new_local_repository(
      name = "erlnif",
      path = "erlnif/include",
      build_file_content = build_file_content
    )
