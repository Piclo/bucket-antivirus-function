FROM amazonlinux:2

# Install packages
RUN yum install -y --setopt skip_missing_names_on_install=False \
        cpio \
        less \
        python3-pip \
        unzip \
        yum-utils \
        zip \
        https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
    && yum clean all

# Download libraries we need to run in lambda
RUN set -x && \
    mkdir -p /tmp/packages && \
    yumdownloader -x \*i686 --archlist=x86_64 --destdir=/tmp/packages \
        clamav \
        clamav-lib \
        clamav-update \
        json-c \
        pcre2 \
        libprelude \
        gnutls \
        libtasn1 \
        nettle \
    && \
    cd /tmp/packages && \
    rpm2cpio clamav-0*.rpm | cpio -idm && \
    rpm2cpio clamav-lib*.rpm | cpio -idm && \
    rpm2cpio clamav-update*.rpm | cpio -idm && \
    rpm2cpio json-c*.rpm | cpio -idm && \
    rpm2cpio pcre*.rpm | cpio -idm && \
    rpm2cpio libprelude*.rpm | cpio -idm && \
    rpm2cpio gnutls*.rpm | cpio -idm && \
    rpm2cpio libtasn1*.rpm | cpio -idm && \
    rpm2cpio nettle*.rpm | cpio -idm && \
    rm -v *.rpm

# Copy over the binaries and libraries
WORKDIR /app
RUN mkdir -p bin && \
    cd /tmp/packages && \
    cp usr/bin/{clamscan,freshclam} usr/lib64/* /app/bin/

# Configure freshclam
COPY freshclam.conf bin/

# Install Python dependencies
COPY requirements.txt ./
RUN pip3 install --no-cache -r requirements.txt

# Create the zip file
COPY *.py ./
RUN mkdir -p build && \
    zip -r9 --exclude="*test*" /app/build/lambda.zip *.py bin && \
    cd /usr/local/lib/python3.7/site-packages && \
    zip -r9 /app/build/lambda.zip *
