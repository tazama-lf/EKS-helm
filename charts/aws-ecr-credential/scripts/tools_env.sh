#!/bin/bash

if [[ "$0" = "$BASH_SOURCE" ]]; then
    echo "###"
    echo "WARNING: Script may not be sourced - exports may not take effect!"
    echo "###"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

export KUBECTL_EXE="${SCRIPT_DIR}/kubectl"

if [[ ! -f "${KUBECTL_EXE}" ]]; then
    set -x
    curl -Lo "${KUBECTL_EXE}" "https://storage.googleapis.com/kubernetes-release/release/v1.18.6/bin/linux/amd64/kubectl"
    chmod +x "${KUBECTL_EXE}"
    set +x
fi

export HELM_EXE="${SCRIPT_DIR}/helm"

if [[ ! -f "${HELM_EXE}" ]]; then
    HELM_TGZ="${HELM_EXE}.tar.gz"
    set -x
    ARCH=$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n $(uname -m) ;; esac)
    OS=$(uname | awk '{print tolower($0)}')
    curl -Lo "${HELM_TGZ}" "https://get.helm.sh/helm-v3.2.4-${OS}-${ARCH}.tar.gz"
    tar -xvf "${HELM_TGZ}" -C "${SCRIPT_DIR}" "${OS}-${ARCH}/helm"
    mv "${SCRIPT_DIR}/${OS}-${ARCH}/helm" "${HELM_EXE}"
    rm -rf "${HELM_TGZ}" "${SCRIPT_DIR}/${OS}-${ARCH}"
    chmod +x "${HELM_EXE}"
    set +x
fi

export KIND_EXE="${SCRIPT_DIR}/kind"

if [[ ! -f "${KIND_EXE}" ]]; then
    set -x
    curl -Lo "${KIND_EXE}" https://kind.sigs.k8s.io/dl/v0.9.0/kind-linux-amd64
    chmod +x "${KIND_EXE}"
    set +x
fi

export YQ_EXE="${SCRIPT_DIR}/yq"

if [[ ! -f "${YQ_EXE}" ]]; then
    set -x
    curl -Lo "${YQ_EXE}" https://github.com/mikefarah/yq/releases/download/3.4.0/yq_linux_amd64
    chmod +x "${YQ_EXE}"
    set +x
fi

export PATH="${SCRIPT_DIR}:${PATH}"