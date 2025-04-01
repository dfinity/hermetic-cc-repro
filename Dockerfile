# https://hub.docker.com/_/ubuntu
# focal-20240216
FROM ubuntu@sha256:48c35f3de33487442af224ed4aabac19fd9bfbd91ee90e9471d412706b20ba73


ENV TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive

RUN apt -yq update && apt -yqq install --no-install-recommends curl lsb-release wget software-properties-common gnupg build-essential autoconf autotools-dev


ARG bazelisk_sha=fd8fdff418a1758887520fa42da7e6ae39aefc788cf5e7f7bb8db6934d279fc4
RUN curl -fsSL https://github.com/bazelbuild/bazelisk/releases/download/v1.25.0/bazelisk-linux-amd64 -o /usr/bin/bazel && \
    echo "$bazelisk_sha /usr/bin/bazel" | sha256sum --check && \
    chmod 777 /usr/bin/bazel

RUN apt -yqq install gnupg

RUN wget -qO- https://apt.llvm.org/llvm.sh | bash -s -- 14

RUN useradd -ms /bin/bash ubuntu

USER ubuntu

RUN which clang-14

RUN mkdir -p "$HOME/hermetic-cc-repro"

ENV USE_BAZEL_VERSION="7.6.0"
ENV CC=clang-14

WORKDIR /home/ubuntu/hermetic-cc-repro


COPY MODULE.bazel /home/ubuntu/hermetic-cc-repro/
COPY BUILD.bazel /home/ubuntu/hermetic-cc-repro/
COPY WORKSPACE.bazel /home/ubuntu/hermetic-cc-repro/
COPY jemalloc /home/ubuntu/hermetic-cc-repro/jemalloc

RUN bazel version
RUN ls jemalloc
RUN bazel build @jemalloc//:libjemalloc
