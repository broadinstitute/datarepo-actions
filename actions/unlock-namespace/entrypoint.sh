#!/bin/sh

set -eu

kubectl delete secret -n "${NAMESPACEINUSE}" "${NAMESPACEINUSE}-inuse"
