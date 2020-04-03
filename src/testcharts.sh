#!/bin/bash
checkpodstatus () {
  passedpods=()
  failedpods=()
  runcounter=0
  for i in $(echo $helm_charts_to_test | sed "s/,/ /g")
  do
    podstatus=$(kubectl get pods --namespace ${charttestnamespace} -l "app.kubernetes.io/name=${i}" -o json | jq -r '.items[].status.containerStatuses[]')
    name=$(jq -r .name <<< ${podstatus})
    ready=$(jq -r .ready <<< ${podstatus})
    restartCount=$(jq -r .restartCount <<< ${podstatus})
    state=$(jq '.state| to_entries[] | {"status": .key} | .status' <<< ${podstatus} | sed 's/"//g')
    if [[ "${state}" == "running" ]] && [[ "${ready}" == true ]]; then
      printf "Pod ${name} running normally...\n"
      passedpods+=($name)
    elif [[ "${state}" == "waiting" ]] && [ "${restartCount}" -gt "5" ]; then
      reason=$(jq -r '.state.waiting.reason' <<< ${podstatus})
      printf "Pod ${name} has restarted more than 5 times failed simple test...\ndebug output: ${reason}...\n"
      failedpods+=(${name})
    elif [[ "${state}" == "running" ]] && [[ "${ready}" == false ]] && [ "${restartCount}" -gt "5" ]; then
      reason=$(jq -r '.state.waiting.reason' <<< ${podstatus})
      printf "Pod ${name} has restarted more than 5 times failed simple test...\nCould be waiting for another pod or probe not ready"
      printf "debug output\n"
      printf "${podstatus}\n"
      failedpods+=(${name})
    elif [[ "${state}" == "running" ]] && [[ "${ready}" == false ]] && [ "${restartCount}" -le "5" ]; then
      printf "Pod ${name} not ready rechecking for more than 5 pod restarts...\n"
      sleep 20
      checknamespace
    elif [[ "${state}" == "waiting" ]] && [ "${restartCount}" -le "5" ]; then
      printf "Pod ${name} waiting rechecking for more than 5 pod restarts...\n"
      sleep 20
      checknamespace
    elif [[ "${podstatus}" == "" ]]; then
      printf "Nothing is deployed for ${i}\n"
      printf "waiting 5 and rechecking"
      ((runcounter+=1))
      sleep 5
      checknamespace
    elif [ "${runcounter}" -gt 5 ]; then
      printf "Check script has looped 5 times exiting"
      exit 1
    else
      printf "unknown state exiting\ndebug output"
      printf -------------
      printf "name:$name"
      printf -------------
      printf "ready:$ready"
      printf -------------
      printf "restartCount:$restartCount"
      printf -------------
      printf "state:$state"
      exit 2
    fi
  done
  printf "\n\n\n\n"
}

printpodstatus () {
  if [[ "${passedpods}" != "" ]]; then
    printf "Passing pods:\n- ${passedpods[*]}\n"
  else
    printf "No Passing pods\n"
  fi
  if [[ "${failedpods}" != "" ]]; then
    printf "Failed pods:\n- ${failedpods[*]}\n"
    exit 1
  else
    printf "No failed pods\n"
  fi
}

testcharts () {
  checkpodstatus
  printpodstatus
}