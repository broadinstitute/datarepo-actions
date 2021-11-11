FROM docker:17.12.0-ce as static-docker-source

FROM openjdk:11-slim
# FROM openjdk:11-slim

USER 1001
ARG CLOUD_SDK_VERSION=334.0.0
ENV CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION \
    CLOUDSDK_PYTHON=python3 \
    HELM_VERSION=v3.1.2 \
    YQ_VERSION=3.2.1 \
    VAULT_VERSION=1.3.2 \
    VAULT_ADDR='https://clotho.broadinstitute.org:8200' \
    VAULT_TOKEN="" \
    GRADLE_HOME=/usr/local/bin/gradle \
    GRADLE_VERSION=4.7

# install google sdk
ARG INSTALL_COMPONENTS
ENV PATH "$PATH:/opt/google-cloud-sdk/bin/"
COPY --from=static-docker-source /usr/local/bin/docker /usr/local/bin/docker
RUN apt-get update -qqy && apt-get install -qqy \
        curl \
        wget \
        gcc \
        python3-dev \
        python3-pip \
        apt-transport-https \
        lsb-release \
        openssh-client \
        ca-certificates \
        openssl \
        git \
        postgresql-client \
        iproute2 \
        jq \
        unzip \
        gnupg && \
    pip3 install -U crcmod && \
    export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update && apt-get install -y google-cloud-sdk=${CLOUD_SDK_VERSION}-0 $INSTALL_COMPONENTS && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image && \
    gcloud --version

COPY ./lib/semver ./lib/semver
RUN install ./lib/semver /usr/local/bin

VOLUME ["/root/.config"]

# install kubectl needs to be after sdk install
RUN apt-get update -qqy && apt-get install -qqy \
  kubectl

# install helm
RUN wget -q https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
  && chmod +x /usr/local/bin/helm && \
  rm -rf helm-${HELM_VERSION}-linux-amd64.tar.gz

# install vault
ADD https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip /

RUN unzip vault_${VAULT_VERSION}_linux_amd64.zip && \
    mv vault /usr/local/bin/vault && \
    rm -rf /vault_${VAULT_VERSION}_linux_amd64.zip

# install yq
RUN wget -O /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" && \
  chmod +x /usr/local/bin/yq


# copy down action functions
COPY ["src", "/src/"]
RUN chmod -R +x /src

# install gradle
ARG GRADLE_DOWNLOAD_SHA256=fca5087dc8b50c64655c000989635664a73b11b9bd3703c7d6cabd31b7dcdb04
RUN set -o errexit -o nounset \
  && echo "Downloading Gradle" \
  && wget -O gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
  \
  && echo "Checking download hash" \
  && echo "${GRADLE_DOWNLOAD_SHA256} *gradle.zip" | sha256sum -c - \
  \
  && echo "Installing Gradle" \
  && unzip gradle.zip \
  && rm gradle.zip \
  && mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
  && ln -s "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle

RUN set -o errexit -o nounset \
	&& echo "Testing Gradle installation" \
	&& gradle --version

# clean cache apks
RUN apt-get clean -qqy

ENTRYPOINT ["/src/main.sh"]
