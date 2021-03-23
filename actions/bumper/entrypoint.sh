#!/bin/sh

# based off https://github.com/anothrNick/github-tag-action

set -eu

# input configuration and defaults
RELEASE_BRANCH_LIST=${INPUT_RELEASE_BRANCH_LIST:-develop,master}
DEFAULT_SEMVER_BUMP=${INPUT_SEMVER_BUMP:-minor}
VERSION_FILE_PATH=${INPUT_VERSION_FILE_PATH:-}
INITIAL_VERSION=${INPUT_INITIAL_VERSION:-0.0.0}
SEMVER_WITH_V=${INPUT_SEMVER_WITH_V:-false}

# use comma as input field separator
PREVIFS=${IFS}
IFS=','

# check whether we are on a prerelease branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
PRE_RELEASE=true
for BRANCH in ${RELEASE_BRANCH_LIST} ; do
    if expr "${CURRENT_BRANCH}" : "${BRANCH}" 1>/dev/null; then
        PRE_RELEASE=false
    fi
done

# restore previous IFS variable
IFS=${PREVIFS}

# get all commits since last semantic version
CURRENT_SEMVER=$(git for-each-ref --sort=-v:refname --count=1 --format '%(refname)' refs/tags/[0-9]*.[0-9]*.[0-9]* refs/tags/v[0-9]*.[0-9]*.[0-9]* | cut -d / -f 3-)
if [ -z "${CURRENT_SEMVER}" ]; then
    echo "No semantic versions. Starting from ${INITIAL_VERSION}"
    GIT_LOG=$(git log --pretty='%B')
    CURRENT_SEMVER="${INITIAL_VERSION}"
    CURRENT_COMMIT=$(git show -s --format=%H)
else
    GIT_LOG=$(git log "${CURRENT_SEMVER}..HEAD" --pretty='%B')
    SEMVER_COMMIT=$(git rev-list -n 1 "${CURRENT_SEMVER}")
    CURRENT_COMMIT=$(git rev-parse HEAD)

    if [ "${SEMVER_COMMIT}" = "${CURRENT_COMMIT}" ]; then
        echo "No new commits since previous semantic version. Skipping semantic version bump."
        exit 0
    fi
fi

printf "### Commits since %s: ###\n\n%s\n\n### End of commits ###\n\n" "${CURRENT_SEMVER}" "${GIT_LOG}"

# bump the semantic version using the default bump level or exit if default is "none"
defaultbump() {
    if [ "${DEFAULT_SEMVER_BUMP}" = "none" ]; then
        echo "Default bump was set to none. Skipping semantic version bump."
        exit 0
    else
        semver bump "${DEFAULT_SEMVER_BUMP}" "${CURRENT_SEMVER}"
    fi
}

# bump semantic version if log contains keyword or bump using default bump level
case "${GIT_LOG}" in
    *#major* ) NEXT_SEMVER=$(semver bump major "${CURRENT_SEMVER}"); SEMVER_PART="major" ;;
    *#minor* ) NEXT_SEMVER=$(semver bump minor "${CURRENT_SEMVER}"); SEMVER_PART="minor" ;;
    *#patch* ) NEXT_SEMVER=$(semver bump patch "${CURRENT_SEMVER}"); SEMVER_PART="patch" ;;
    * ) NEXT_SEMVER=$(defaultbump); SEMVER_PART=${DEFAULT_SEMVER_BUMP} ;;
esac

# prefix semantic version with v
if ${SEMVER_WITH_V} ; then
    NEXT_SEMVER="v${NEXT_SEMVER}"
fi

# add commit short hash
if ${PRE_RELEASE} ; then
    SHORT_HASH=$(echo "${CURRENT_COMMIT}" | cut -c1-8)
    NEXT_SEMVER="${NEXT_SEMVER}-${SHORT_HASH}"
fi

echo "Bumping ${SEMVER_PART} version from ${CURRENT_SEMVER} to ${NEXT_SEMVER}"

if ${PRE_RELEASE} ; then
    echo "This branch is not a release branch. Skipping semantic version bump."
    exit 0
fi

# bump the version in the file located at ${VERSION_FILE_PATH}
# TODO: work to be done to configure this for non-snapshot releases
if [ -z "${VERSION_FILE_PATH}" ]; then
    echo "Skipping bump of version file."
else
    KNOWN_EXTENSION=false
    case "${VERSION_FILE_PATH}" in
        *.gradle ) sed -i "s/    version.*/    version '${NEXT_SEMVER}-SNAPSHOT'/" "${VERSION_FILE_PATH}" ; KNOWN_EXTENSION=true ;;
        *.json) sed -i "s/\"version\":.*/\"version\": \"${NEXT_SEMVER}\",/" "${VERSION_FILE_PATH}" ; KNOWN_EXTENSION=true ;;
        *) echo "Unknown file extension. Skipping bump of version file." ; exit 0 ;;
    esac
    if ${KNOWN_EXTENSION} ; then
        # configure git settings
        git config --global user.email "broadbot@broadinstitute.org"
        git config --global user.name "broadbot"
        git config pull.rebase false
        # commit changes to repository
        git pull origin master
        git add "${VERSION_FILE_PATH}"
        git commit -m "Bump to ${NEXT_SEMVER}"
        # push changes to master branch
        git push origin "${CURRENT_BRANCH}"
        git rev-parse HEAD
    fi
fi

# add the latest semantic version to git tags
if [ -n "${GITHUB_REPOSITORY}" ]; then
    CURRENT_DATE=$(date '+%Y-%m-%dT%H:%M:%SZ')
    GIT_REFS_URL=$(jq .repository.git_refs_url "${GITHUB_EVENT_PATH}" | tr -d '"' | sed 's/{\/sha}//g')

    echo "${CURRENT_DATE}: Pushing ${NEXT_SEMVER} to ${GITHUB_REPOSITORY}"

    curl -s -X POST "${GIT_REFS_URL}" \
        -H "Authorization: token ${INPUT_GITHUB_TOKEN}" \
        -d @- << EOF
{
    "ref": "refs/tags/${NEXT_SEMVER}",
    "sha": "${CURRENT_COMMIT}"
}
EOF

fi
