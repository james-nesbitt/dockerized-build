FROM alpine:3

RUN ln -s /usr/share/zoneinfo/UTC /etc/localtime
RUN apk add --no-cache --update python3 python3-dev py3-pip bash zsh docker build-base alpine-sdk gcc openssh rsync tzdata jq libc6-compat sudo libressl-dev musl-dev libffi-dev

RUN curl -L -o helm.tgz https://get.helm.sh/helm-v3.5.2-linux-amd64.tar.gz \
 && tar -xzf helm.tgz \
 && chown -R root:root linux-amd64/helm \
 && chmod a+x linux-amd64/helm \
 && mv linux-amd64/helm /usr/local/bin/helm \
 && rm -rf helm.tgz linux-amd64

RUN curl -L -o sonobuoy.tgz https://github.com/vmware-tanzu/sonobuoy/releases/download/v0.50.0/sonobuoy_0.50.0_linux_amd64.tar.gz \
 && tar -xzf sonobuoy.tgz \
 && chown -R root:root sonobuoy \
 && chmod a+x sonobuoy \
 && mv sonobuoy /usr/local/bin/sonobuoy \
 && rm -rf sonobuoy.tgz

RUN curl -fsSL -o /usr/local/bin/kubectl https://dl.k8s.io/release/v1.20.0/bin/linux/amd64/kubectl \
 && chmod a+x /usr/local/bin/kubectl

RUN curl -fsSL -o terraform.zip https://releases.hashicorp.com/terraform/0.14.8/terraform_0.14.8_linux_amd64.zip \
 && unzip terraform.zip \
 && mv terraform /usr/local/bin \
 && rm terraform.zip

RUN curl -L -o /usr/local/bin/launchpad https://github.com/Mirantis/launchpad/releases/download/1.2.0/launchpad-linux-x64 \
 && chmod a+x /usr/local/bin/launchpad
#COPY bin/* /usr/local/bin/

# RUN pip3 install "ansible==3.1.0"
RUN apk add --no-cache --update ansible

RUN adduser --shell /bin/zsh --uid=1000 --disabled-password build \
 && addgroup build docker \
 && echo "build  ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/buildall \
 && echo "alias docker='sudo docker'" >> /etc/profile.d/dockersudo
USER build
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
 && echo "alias docker='sudo /usr/bin/docker'" >> ~/.profile \
 && echo "alias python='sudo /usr/bin/python3'" >> ~/.profile \
 && echo "alias docker='sudo /usr/bin/docker'" >> ~/.zshrc \
 && echo "alias python='sudo /usr/bin/python3'" >> ~/.zshrc
ENV PATH="$PATH:/home/build/.local/bin"

RUN mkdir -p  ~/.ssh && ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

RUN /usr/local/bin/launchpad register --name "PRODENG" --company "Mirantis Inc" --email "testing@mirantis.com" --disable-telemetry --disable-upgrade-check  --accept-license

ENTRYPOINT /bin/zsh
