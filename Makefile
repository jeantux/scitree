# MIX_APP_PATH is injected by scitree nifs

PROJECT_NAME=scitree
PRIV_DIR=$(MIX_APP_PATH)/priv

BAZEL_FLAGS=--config=linux_cpp17 \
	--config=linux_avx2 \
	--experimental_ui_max_stdouterr_bytes=1073741819 \
	--copt=-fpic

all: $(PROJECT_NAME)

$(PROJECT_NAME):
		cd ./c_src && \
		bazel build $(BAZEL_FLAGS) //scitree && \
		mkdir -p $(PRIV_DIR) && \
		rm -f $(PRIV_DIR)/scitree.so &&\
		cp ./bazel-out/k8-opt/bin/scitree/scitree $(PRIV_DIR)/scitree.so

clean:
		cd ./c_src && \
		bazel clean
