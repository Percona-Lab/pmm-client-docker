#!/bin/bash

set -o errexit

# Add logging
if [ -n "${ENABLE_DEBUG}" ]; then
    set -o xtrace
    exec > >(tee -a /var/log/$(basename $0).log) 2>&1
fi

if [ -z "${PMM_SERVER}" ]; then
    echo PMM_SERVER is not specified. exiting
    exit 1
fi
if [ -n "${PMM_USER}" ]; then
    ARGS+=" --server-user ${PMM_USER}"
fi
if [ -n "${PMM_PASSWORD}" ]; then
    ARGS+=" --server-password ${PMM_PASSWORD}"
fi


SRC_ADDR=$(ip route get "${PMM_SERVER}" | grep 'src ' | awk '{print$7}')

pmm-admin config \
    --non-root \
    --server "${PMM_SERVER}" \
    --server-insecure-ssl \
    --bind-address "${SRC_ADDR}" \
    --client-address "${SRC_ADDR}" \
    ${ARGS}

if [ -n "${DB_USER}" ]; then
    DB_ARGS+=" --user ${DB_USER}"
fi
if [ -n "${DB_PASSWORD}" ]; then
    DB_ARGS+=" --password ${DB_PASSWORD}"
fi

if [ -n "${DB_TYPE}" -a -n "${DB_HOST}" ]; then
    pmm-admin add "${DB_TYPE}" \
        --non-root \
        --host "${DB_HOST}" \
        ${DB_ARGS}
fi

exec /usr/bin/monit -I
