#!/bin/bash

# taken from https://github.com/anothrNick/github-tag-action

bumper () {
    # config
    default_semvar_bump=${DEFAULT_BUMP:-minor}
    with_v=${WITH_V:-false}
    release_branches=${INPUT_RELEASE_BRANCHES:-develop,master,sh-dr-1510-test}
    custom_tag=${CUSTOM_TAG}
    source=${SOURCE:-.}
    dryrun=${DRY_RUN:-false}
    initial_version=${INITIAL_VERSION:-0.0.0}

    cd ${GITHUB_WORKSPACE}/${source}

    current_branch=$(git rev-parse --abbrev-ref HEAD)

    pre_release="true"
    IFS=',' read -ra branch <<< "$release_branches"
    for b in "${branch[@]}"; do
        echo "Is $b a match for ${current_branch}"
        if [[ "${current_branch}" =~ $b ]]
        then
            pre_release="false"
        fi
    done
    echo "pre_release = $pre_release"

    # fetch tags
    git fetch --tags

    # get latest tag that looks like a semver (with or without v)
    tag=$(git for-each-ref --sort=-v:refname --count=1 --format '%(refname)' refs/tags/[0-9]*.[0-9]*.[0-9]* refs/tags/v[0-9]*.[0-9]*.[0-9]* | cut -d / -f 3-)

    # if there are none, start tags at INITIAL_VERSION which defaults to 0.0.0
    if [ -z "$tag" ]; then
        log=$(git log --pretty='%B')
        tag="$initial_version"
        commit=$(git show -s --format=%H)
    else
        log=$(git log $tag..HEAD --pretty='%B')
        tag_commit=$(git rev-list -n 1 $tag)
        commit=$(git rev-parse HEAD)

        if [ "$tag_commit" == "$commit" ]; then
            echo "No new commits since previous tag. Skipping..."
            echo ::set-output name=tag::$tag
            exit 0
        fi
    fi

    echo $log

    # this will bump the semvar using the default bump level,
    # or it will simply pass if the default was "none"
    function default-bump {
      if [ "$default_semvar_bump" == "none" ]; then
        echo "Default bump was set to none. Skipping..."
        exit 0
      else
        semver bump "${default_semvar_bump}" $tag
      fi
    }

    # get commit logs and determine home to bump the version
    # supports #major, #minor, #patch (anything else will be 'minor')
    case "$log" in
        *#major* ) new=$(semver bump major $tag); part="major";;
        *#minor* ) new=$(semver bump minor $tag); part="minor";;
        *#patch* ) new=$(semver bump patch $tag); part="patch";;
        * ) new=$(default-bump); part=$default_semvar_bump;;
    esac

    echo $part

    # did we get a new tag?
    if [ ! -z "$new" ]
    then
            # prefix with 'v'
            if $with_v
            then
                            new="v$new"
            fi

            if $pre_release
            then
                            new="$new-${commit:0:7}"
            fi
    fi

    if [ ! -z $custom_tag ]
    then
        new="$custom_tag"
    fi

    echo $new

    # set outputs
    echo ::set-output name=new_tag::$new
    echo ::set-output name=part::$part

    # use dry run to determine the next tag
    if $dryrun
    then
        echo ::set-output name=tag::$tag
        exit 0
    fi

    echo ::set-output name=tag::$new

    if $pre_release
    then
        echo "This branch is not a release branch. Skipping the tag creation."
        exit 0
    fi

    # bump the version in the file located at ${INPUT_VERSION_FILE_PATH}
    # expects that there is a line of the form: ${INPUT_VERSION_VARIABLE_NAME} 'x.y.z-SNAPSHOT'
    # TODO: work to be done to configure this for non-snapshot releases
    if [ -z "$INPUT_VERSION_FILE_PATH" ] || [ -z "$INPUT_VERSION_VARIABLE_NAME" ]; then
        echo "Skipping bump of version file."
    else
        SUFFIX=SNAPSHOT
        if [ "${INPUT_VERSION_FILE_PATH#*.}" == "gradle" ]; then
            sed -i "s/    ${INPUT_VERSION_VARIABLE_NAME}.*/    ${INPUT_VERSION_VARIABLE_NAME} '${new}-${SUFFIX}'/" $INPUT_VERSION_FILE_PATH
        elif [ "${INPUT_VERSION_FILE_PATH#*.}" == "json" ]; then
            sed -i "s/\"version\":.*/\"version\": \"${new}\",/" $INPUT_VERSION_FILE_PATH
        fi
        git config --global user.email "robot@jade.team"
        git config --global user.name "bumptagbot"
        git add $INPUT_VERSION_FILE_PATH
        git commit -m "bump ${new}"
        git push origin $current_branch
        commit=$(git rev-parse HEAD)
    fi

    # push new tag ref to github
    dt=$(date '+%Y-%m-%dT%H:%M:%SZ')
    full_name=$GITHUB_REPOSITORY
    git_refs_url=$(jq .repository.git_refs_url $GITHUB_EVENT_PATH | tr -d '"' | sed 's/{\/sha}//g')

    echo "$dt: **pushing tag $new to repo $full_name"

    curl -s -X POST $git_refs_url \
    -H "Authorization: token $INPUT_GITHUB_TOKEN" \
    -d @- << EOF

    {
      "ref": "refs/tags/$new",
      "sha": "$commit"
    }
EOF
}
