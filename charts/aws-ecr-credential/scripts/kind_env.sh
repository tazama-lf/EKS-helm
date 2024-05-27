# SPDX-License-Identifier: Apache-2.0

#!/bin/bash

if [[ "$0" = "$BASH_SOURCE" ]]; then
    echo "###"
    echo "WARNING: Script may not be sourced - exports may not take effect!"
    echo "###"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

source "$SCRIPT_DIR/tools_env.sh"

export KUBECONFIG="${SCRIPT_DIR}/.kube/config"

export CLUSTER_NAME="${CLUSTER_NAME:-kind}"

#CLEAN_CLUSTER=
if [[ ! -z "${CLEAN_CLUSTER}" ]]; then
    set -x
    kind delete cluster --name "${CLUSTER_NAME}"
    set +x
fi

EXISTING_CLUSTER="$("${KIND_EXE}" get clusters | grep -e "^${CLUSTER_NAME}\$")"

if [[ -z "${EXISTING_CLUSTER}" ]]; then
    set -x
    kind create cluster --name "${CLUSTER_NAME}"
    set +x
fi

echo ""
echo "KIND clusters:"
kind get clusters

echo ""
echo "Cluster info:"
kubectl cluster-info
