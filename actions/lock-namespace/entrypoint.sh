#!/bin/sh

set -eu

# use comma as input field separator
PREVIFS=${IFS}
IFS=','

# try to lock a specific namespace
while true; do
    for NS in ${K8_NAMESPACES}; do
        if kubectl get secrets -n "${NS}" "${NS}-inuse" > /dev/null 2>&1; then
            echo "Namespace ${NS} in use -- Skipping"
        else
            echo "Namespace ${NS} not in use -- Locking"
            kubectl create secret generic -n "${NS}" "${NS}-inuse" --from-literal=inuse="${NS}"
            echo "NAMESPACEINUSE=${NS}" >> "$GITHUB_ENV"
            echo "::set-output name=namespace::${NS}"
        
            #Set the integration api url
            if echo "${NS}" | grep -q "-"; then
                TAIL=$(echo "${NS}" | awk -F- {'print $2'})
                echo "Stripping - from namespace for IT_JADE_API_URL"
            else
                TAIL=${NS}
                echo "using full namespace for IT_JADE_API_URL"
            fi
            API_URL="https://jade-${TAIL}.datarepo-integration.broadinstitute.org"
            echo "IT_JADE_API_URL=${API_URL}"
            echo "::set-output name=api_url::${API_URL}"
            
            # break out of double loop
            break 2
        fi
    done
    echo "All namespaces currently in use -- Retrying"
    sleep 120
done

# restore previous IFS variable
IFS=${PREVIFS}
