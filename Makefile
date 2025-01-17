DOCKER_BAZEL_IMG=gcr.io/cloud-marketplace-containers/google/bazel:1.0.0
DOCKER_RK_STORAGE_IMG=repository-master.rubrik.com:5000/bazel/bb_storage

SRC_DIR=$(CURDIR)
DOCKER_WORK_DIR=/src/workspace
OUT_DIR=/tmp/bazel-output
DOCKER_OUT_DIR=/tmp/bazel-output
DOCKER_LOAD_STORAGE_IMG=bazel/cmd/bb_storage:bb_storage_container

BAZEL_RESULT_DIR=$(CURDIR)/bazel-result

BAZEL_CLIENT_CFG=--output_user_root=$(DOCKER_OUT_DIR)

STORAGE_TARGET=bb_storage_container.tar

all: clean bb-storage

.NOTPARALLEL:

bb-storage:
	docker run \
		-v $(SRC_DIR):$(DOCKER_WORK_DIR) \
		-v $(OUT_DIR):$(DOCKER_OUT_DIR) \
		-w $(DOCKER_WORK_DIR) \
		-it $(DOCKER_BAZEL_IMG) \
		$(BAZEL_CLIENT_CFG) build //cmd/bb_storage:$(STORAGE_TARGET)
	mkdir -p $(BAZEL_RESULT_DIR)
	cp bazel-bin/cmd/bb_storage/$(STORAGE_TARGET) $(BAZEL_RESULT_DIR)

bb-docker-push:
	$(eval timestamp := $(shell date -u +%Y%m%dT%H%M%SZ))
	$(eval githash := $(shell git rev-parse --short HEAD))
	$(eval dockertag := $(timestamp)_$(githash))
	# TODO/sarath: don't push if githash is the same
	docker load -i $(BAZEL_RESULT_DIR)/$(STORAGE_TARGET)
	docker image tag $(DOCKER_LOAD_STORAGE_IMG) $(DOCKER_RK_STORAGE_IMG):$(dockertag)
	docker push $(DOCKER_RK_STORAGE_IMG):$(dockertag)

test:
	bazel test pkg/...

clean:
	rm -rf $(BAZEL_RESULT_DIR)/$(STORAGE_TARGET) bazel-bin bazel-workspace bazel-testlogs bazel-out
