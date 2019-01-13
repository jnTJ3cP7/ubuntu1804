#!/bin/zsh

###################################################
# This provision script depends on below provisions
#   - docker
###################################################
! which docker >/dev/null && echo 'please provision docker before k8s provision' && exit 1

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

MINIKUBE_DASHBOARD_URL="http://${PRIVATE_IP}:8001/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/"
if ! fgrep -q "$MINIKUBE_DASHBOARD_URL" ~/.zprofile; then
  which minikube >/dev/null || {curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo cp minikube /usr/local/bin/ && rm minikube}
  which kubectl >/dev/null || {curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl && sudo cp kubectl /usr/local/bin/ && rm kubectl}

  mkdir -p $HOME/.kube
  mkdir -p $HOME/.minikube
  touch $HOME/.kube/config

  if ! fgrep -q "$HOME/.kube/config" ~/.zshrc; then
    cat << EOS >> ~/.zshrc
# for kubectl completion
source <(kubectl completion zsh)

# for minikube with vm-dirver=none
export MINIKUBE_WANTUPDATENOTIFICATION=false
export MINIKUBE_WANTREPORTERRORPROMPT=false
export MINIKUBE_HOME=$HOME
export CHANGE_MINIKUBE_NONE_USER=true
export KUBECONFIG=$HOME/.kube/config

EOS
  fi

  source ~/.zshrc 2>/dev/null

  sudo -E minikube start --vm-driver=none 2>/dev/null

  # this for loop waits until kubectl can access the api server that Minikube has created
  for i in {1..150}; do # timeout for 5 minutes
     kubectl get po &> /dev/null
     if [ $? -ne 1 ]; then
        echo 'minikube starts successfully !'
        break
    fi
    sleep 2
    false
  done
  [ $? -ne 0 ] && { echo 'minikube start failed' && exit 1 }

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

  sudo systemctl daemon-reload
  sudo systemctl start minikube-proxy.service || {echo 'minikube proxy start failed' && exit 1}
  sudo systemctl enable minikube-proxy.service

  cat << EOS >> ~/.zprofile
# for minikube dashboard informatino notification to prevent URL forget
echo "If minikube settings are default, dashboard URL is below (maybe take a while until start up)\n${MINIKUBE_DASHBOARD_URL}"

EOS
fi
