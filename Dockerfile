FROM alpine

RUN apk add --no-cache --update python3 py3-pip bash zsh docker alpine-sdk bash terraform ansible openssh rsync tzdata jq
RUN curl -L -o /usr/local/bin/launchpad https://github.com/Mirantis/launchpad/releases/download/1.2.0-beta.11/launchpad-linux-x64 \
 && chmod a+x /usr/local/bin/launchpad
RUN ln -s /usr/share/zoneinfo/UTC /etc/localtime

RUN mkdir -p  ~/.ssh && ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

RUN launchpad --accept-license register --name "Automation" --company "Mirantis Inc" --email "testing@mirantis.com"
