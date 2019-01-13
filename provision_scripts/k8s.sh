#!/bin/zsh

###################################################
# This provision script depends on below provisions
#   - docker
###################################################
if ! which docker >/dev/null; then
	echo 'please provision docker before k8s provision'
	exit 1
fi

# params check
# arg 1 is Private IP of VM
case $# in
	0)
		echo 'Private IP is not specified'
		exit 1
		;;
	1)
    PRIVATE_IP=$1
		;;
	*)
		echo 'Unexpected params exist'
		exit 1
		;;
esac

if ! [ -f /etc/systemd/system/minikube-proxy.service ]; then
  curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo cp minikube /usr/local/bin/ && rm minikube
  curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl && sudo cp kubectl /usr/local/bin/ && rm kubectl

  mkdir -p $HOME/.kube
  mkdir -p $HOME/.minikube
  touch $HOME/.kube/config

  cat << EOS >> ~/.zshrc
# for kubectl completion
source <(kubectl completion zsh)

# for minikube with vm-dirver=none
export MINIKUBE_WANTUPDATENOTIFICATION=false
export MINIKUBE_WANTREPORTERRORPROMPT=false
export MINIKUBE_HOME=$HOME
export CHANGE_MINIKUBE_NONE_USER=true
export KUBECONFIG=$HOME/.kube/config
echo "If minikube becomes to be default settigns, dashboard URL is below (maybe take a while until start up)\nhttp://${PRIVATE_IP}:8001/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/#!/persistentvolume?namespace=default"

EOS
  source ~/.zshrc 2>/dev/null

  sudo -E minikube start --vm-driver=none

  # this for loop waits until kubectl can access the api server that Minikube has created
  for i in {1..150}; do # timeout for 5 minutes
     kubectl get po &> /dev/null
     if [ $? -ne 1 ]; then
        break
    fi
    sleep 2
  done

  KUBECTL_PATH=$(which kubectl)
  USER_HOME=$HOME
  sudo sh -c "cat << EOF > /etc/systemd/system/minikube-proxy.service
[Unit]
Description=minikube proxy start service

[Service]
ExecStart=${KUBECTL_PATH} proxy --address=0.0.0.0 --accept-hosts='.*' --kubeconfig=${USER_HOME}/.kube/config
Restart=always

[Install]
WantedBy=multi-user.target
EOF"

  sudo systemctl start minikube-proxy.service
  sudo systemctl enable minikube-proxy.service
fi
