#!/bin/bash

set -e

echo "=========================================="
echo " Kubernetes Cluster Setup"
echo "=========================================="

MASTER_IP="${MASTER_IP:-}"

if [ -z "$MASTER_IP" ]; then
    echo "ERROR: MASTER_IP is not set."
    echo ""
    echo "Example:"
    echo "export MASTER_IP=172.31.x.x"
    echo "./setup-k8s-nodes.sh"
    exit 1
fi

echo "Master IP: $MASTER_IP"

# ------------------------------------------
# Check required commands
# ------------------------------------------

echo ""
echo "Checking required Kubernetes components..."

command -v kubeadm >/dev/null 2>&1 || {
    echo "ERROR: kubeadm is not installed."
    echo "Run kubernetes.sh first."
    exit 1
}

command -v kubelet >/dev/null 2>&1 || {
    echo "ERROR: kubelet is not installed."
    echo "Run kubernetes.sh first."
    exit 1
}

command -v kubectl >/dev/null 2>&1 || {
    echo "ERROR: kubectl is not installed."
    echo "Run kubernetes.sh first."
    exit 1
}

# ------------------------------------------
# Detect current node IP
# ------------------------------------------

NODE_IP=$(hostname -I | awk '{print $1}')

echo ""
echo "Detected Node IP: $NODE_IP"

# ------------------------------------------
# Ask what type of node
# ------------------------------------------

echo ""
echo "Select node type:"
echo ""
echo "1) Control Plane / Master"
echo "2) Worker"
echo ""

read -rp "Enter choice [1/2]: " NODE_TYPE

# ------------------------------------------
# MASTER NODE
# ------------------------------------------

if [ "$NODE_TYPE" = "1" ]; then

    echo ""
    echo "=========================================="
    echo " Initializing Control Plane"
    echo "=========================================="

    sudo kubeadm init \
        --apiserver-advertise-address="$NODE_IP" \
        --pod-network-cidr=10.244.0.0/16

    echo ""
    echo "=========================================="
    echo " Configuring kubectl"
    echo "=========================================="

    mkdir -p "$HOME/.kube"

    sudo cp -i /etc/kubernetes/admin.conf "$HOME/.kube/config"

    sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"

    echo ""
    echo "=========================================="
    echo " Control Plane Initialized"
    echo "=========================================="

    echo ""
    echo "Check cluster:"
    echo "kubectl get nodes"

    echo ""
    echo "IMPORTANT:"
    echo "Deploy your CNI before joining worker nodes."
    echo ""
    echo "For example, Calico can be installed separately."
    echo ""

    echo "Generate worker join command using:"
    echo ""
    echo "kubeadm token create --print-join-command"

# ------------------------------------------
# WORKER NODE
# ------------------------------------------

elif [ "$NODE_TYPE" = "2" ]; then

    echo ""
    echo "=========================================="
    echo " Worker Node Setup"
    echo "=========================================="

    echo ""
    echo "You need the join command generated on the"
    echo "control-plane node."
    echo ""
    echo "Example:"
    echo ""
    echo "sudo kubeadm join <MASTER-IP>:6443 \\"
    echo "  --token <TOKEN> \\"
    echo "  --discovery-token-ca-cert-hash sha256:<HASH>"
    echo ""

    read -rp "Paste kubeadm join command: " JOIN_COMMAND

    echo ""
    echo "Joining Kubernetes cluster..."

    sudo $JOIN_COMMAND

    echo ""
    echo "=========================================="
    echo " Worker Node Joined"
    echo "=========================================="

    echo ""
    echo "Run the following on the control-plane:"
    echo ""
    echo "kubectl get nodes"

else

    echo "Invalid option."

    exit 1

fi