FROM ubuntu:jammy

ENV VERSION 1.24.0~dev-103-g1ef9b1b-1
ENV DEBIAN_FRONTEND noninteractive

# Install packages
# For OpenModelica we need ca-certificates, curl, gnupg, lsb-release and cmake
RUN apt update && \
    apt install --no-install-recommends -y \
    git \
    wget \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    cmake \
    xdg-utils && \
    rm -rf /var/lib/apt/lists/*

# Install OpenModelica and Modelica libraries
# Available OMC versions can be found at https://build.openmodelica.org/apt/dists/focal/
RUN curl -fsSL http://build.openmodelica.org/apt/openmodelica.asc | gpg --dearmor -o /usr/share/keyrings/openmodelica-keyring.gpg\
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/openmodelica-keyring.gpg] https://build.openmodelica.org/apt \
    $(lsb_release -cs) nightly" | tee /etc/apt/sources.list.d/openmodelica.list > /dev/null
RUN apt update && apt install --no-install-recommends -y \
    openmodelica=$VERSION 
RUN apt clean && rm -rf /var/lib/apt/lists/*


