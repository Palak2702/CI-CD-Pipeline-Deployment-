#!/bin/bash

set -e

K8S_VERSION="1.28"

echo "=========================================="
echo " Kubernetes Node Preparation"
echo " Kubernetes Version: ${K8S_VERSION}"
echo "=========================================="

# ------------------------------------------
# 1. Update system
# ------------------------------------------

echo "[1/9] Updating system packages..."

sudo apt-get update
sudo apt-get upgrade -y

# ------------------------------------------
# 2. Disable swap
# ------------------------------------------

echo "[2/9] Disabling swap..."

sudo swapoff -a

# Disable swap permanently
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# ------------------------------------------
# 3. Load required kernel modules
# ------------------------------------------

echo "[3/9] Loading kernel modules..."

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# ------------------------------------------
# 4. Configure Kubernetes networking
# ------------------------------------------

echo "[4/9] Configuring kernel networking..."

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# ------------------------------------------
# 5. Install containerd
# ------------------------------------------

echo "[5/9] Installing containerd..."

sudo apt-get install -y containerd

# Create containerd configuration directory
sudo mkdir -p /etc/containerd

# Generate default configuration
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null

# Kubernetes recommends systemd cgroups
sudo sed -i \
's/SystemdCgroup = false/SystemdCgroup = true/' \
/etc/containerd/config.toml

# Restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd

# ------------------------------------------
# 6. Install prerequisites
# ------------------------------------------

echo "[6/9] Installing Kubernetes prerequisites..."

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gpg

# ------------------------------------------
# 7. Add Kubernetes repository
# ------------------------------------------

echo "[7/9] Adding Kubernetes repository..."

sudo mkdir -p -m 755 /etc/apt/keyrings

curl -fsSL \
    https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/Release.key \
    | sudo gpg --dearmor \
    -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/ /" \
| sudo tee /etc/apt/sources.list.d/kubernetes.list

# ------------------------------------------
# 8. Install Kubernetes packages
# ------------------------------------------

echo "[8/9] Installing Kubernetes packages..."

sudo apt-get update

sudo apt-get install -y \
    kubelet \
    kubeadm \
    kubectl

# Prevent automatic version changes
sudo apt-mark hold kubelet kubeadm kubectl

# ------------------------------------------
# 9. Enable kubelet
# ------------------------------------------

echo "[9/9] Enabling kubelet..."

sudo systemctl enable kubelet

echo ""
echo "=========================================="
echo " Kubernetes Installation Completed"
echo "=========================================="

echo ""
echo "Kubeadm:"
kubeadm version

echo ""
echo "Kubelet:"
kubelet --version

echo ""
echo "Kubectl:"
kubectl version --client

echo ""
echo "Containerd:"
containerd --version

echo ""
echo "=========================================="
echo " Node is ready for kubeadm"
echo "=========================================="