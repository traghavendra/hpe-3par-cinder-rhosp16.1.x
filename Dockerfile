# custom cinder-volume container - having python-3parclient
FROM registry.redhat.io/rhosp-rhel8/openstack-cinder-volume:16.1.6-7

MAINTAINER HPE

LABEL name="rhosp16.1.6/openstack-cinder-volume-hpe" \
      maintainer="sneha.rai@hpe.com" \
      vendor="HPE" \
      release="16.1.6" \
      summary="Red Hat OpenStack Platform 16.1.6 cinder-volume HPE plugin" \
      description="Cinder plugin for HPE 3PAR and Primera"

# switch to root and install a custom RPM, etc.
USER "root"

# Copy entitlements
COPY ./etc_pki_entitlement/* /etc/pki/entitlement

# Copy subscription manager configurations
COPY ./rhsm.conf /etc/rhsm
COPY ./etc_rhsm_ca/* /etc/rhsm/ca
COPY ./etc_pki_rpm-gpg/RPM-GPG-KEY-redhat-release /etc/pki/rpm-gpg

# add below command so that, when container is built on 
# RH catalog page, RH 'vulnerability' test gets passed.
RUN yum -y update-minimal --security --sec-severity=Important --sec-severity=Critical

# Remove entitlements and Subscription Manager configs
RUN rm -rf /etc/pki/entitlement && \
    rm -rf /etc/rhsm && \
    rm /etc/rhsm/ca/*
    rm /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release

# install python module python-3parclient(dependent module for HPE 3PAR Cinder driver)
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" && python get-pip.py && pip install -U setuptools && pip install python-3parclient==4.2.11 && rm get-pip.py

RUN mkdir -p /licenses

# Add required license as text file in Liceses directory (GPL, MIT, APACHE, Partner End User Agreement, etc)
COPY LICENSE /licenses

# switch the container back to the default user
USER "cinder"
