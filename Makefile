
PROJECT_NAME=scitree
BAZEL_FLAGS=--config=linux_cpp17 \
	--config=linux_avx2 \
	--experimental_ui_max_stdouterr_bytes=1073741819 \
	--copt=-fpic

all: $(PROJECT_NAME)

$(PROJECT_NAME):
		cd ./c_src && \
		bazel build $(BAZEL_FLAGS) //scitree && \
		rm -f ./scitree/scitree.so && \
		cp ./bazel-out/k8-opt/bin/scitree/scitree ./scitree/scitree.so

clean:
		cd ./c_src && \
		bazel clean
