#!/usr/bin/env bash
# Shared helpers for turning the crisp-client web client into the files the
# CrispClient target needs.

# Echoes the npm version to fetch: <requested> if given, otherwise the pin in
# .crisp-client-version. Pins predating the npm switch are git tags (v4.6.25),
# so a leading v comes off either way.
resolve_crisp_client_version() {
  local requested=$1
  local pin_file="${PWD}/.crisp-client-version"

  if [[ -n "${requested}" ]]; then
    echo "${requested#v}"
    return
  fi

  if [[ ! -s "${pin_file}" ]]; then
    echo "No <version> given and ${pin_file} is missing or empty." >&2
    exit 1
  fi

  local pin
  pin="$(tr -d '[:space:]' < "${pin_file}")"
  echo "${pin#v}"
}

# Writes the npm credentials to <dest_file> as an .npmrc. Prefers
# NPM_PULL_TOKEN, which holds the .npmrc contents verbatim, and otherwise reads
# the 1Password document named by CRISP_CLIENT_OP_ITEM. Either way the token
# reaches npm through a file, never the command line or the repo.
write_npmrc() {
  local dest_file=$1

  if [[ -n "${NPM_PULL_TOKEN:-}" ]]; then
    printf '%s\n' "${NPM_PULL_TOKEN}" > "${dest_file}"
    chmod 600 "${dest_file}"
    echo "Using npm credentials from NPM_PULL_TOKEN."
    return
  fi

  if ! command -v op > /dev/null 2>&1; then
    echo "NPM_PULL_TOKEN is unset and the 1Password CLI (op) is not installed." >&2
    echo "Set NPM_PULL_TOKEN to the contents of your .npmrc, or install op to read \"${CRISP_CLIENT_OP_ITEM:?}\"." >&2
    exit 1
  fi

  if ! op document get "${CRISP_CLIENT_OP_ITEM:?}" > "${dest_file}" 2> /dev/null; then
    echo "Could not read the 1Password document \"${CRISP_CLIENT_OP_ITEM}\"." >&2
    echo "Run 'op signin' and try again, or set NPM_PULL_TOKEN to the contents of your .npmrc." >&2
    exit 1
  fi
  chmod 600 "${dest_file}"
  echo "Loaded npm credentials from 1Password (\"${CRISP_CLIENT_OP_ITEM}\")."
}

# Downloads and unpacks <version> of the CrispClient npm package. <version> is
# anything npm accepts: an exact version, a range, or a dist-tag such as
# 'latest'. Sets WEB_CLIENT_PKG_DIR (the unpacked package root) and
# WEB_CLIENT_VERSION (the version npm actually resolved) for the caller.
pull_web_client_package() {
  local version=$1

  # Deliberately not 'local': the EXIT trap runs after this function has
  # returned, so a local would be out of scope by then and the .npmrc would
  # survive in /tmp. This owns the EXIT trap. Extend it rather than adding a
  # second one.
  WEB_CLIENT_TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "${WEB_CLIENT_TMP_DIR}"' EXIT

  write_npmrc "${WEB_CLIENT_TMP_DIR}/.npmrc"

  local spec="${CRISP_CLIENT_NPM_PACKAGE:?}@${version}"
  echo "Fetching ${spec}…"

  local tarball
  tarball="$(npm pack "${spec}" \
    --userconfig "${WEB_CLIENT_TMP_DIR}/.npmrc" \
    --pack-destination "${WEB_CLIENT_TMP_DIR}" \
    --silent --json | jq -r '.[0].filename')"

  if [[ -z "${tarball}" || ! -f "${WEB_CLIENT_TMP_DIR}/${tarball}" ]]; then
    echo "npm pack produced no tarball for ${spec}." >&2
    exit 1
  fi

  # The tarball unpacks into a top-level 'package' directory.
  tar -xzf "${WEB_CLIENT_TMP_DIR}/${tarball}" -C "${WEB_CLIENT_TMP_DIR}"
  WEB_CLIENT_PKG_DIR="${WEB_CLIENT_TMP_DIR}/package"
  WEB_CLIENT_VERSION="$(jq -r .version "${WEB_CLIENT_PKG_DIR}/package.json")"
}

# Copies the published web client's dist/live into <dest_dist_dir>. The tarball
# ships the standalone build already, so unlike build_web_client_dist there is
# nothing to compile here. Sets WEB_CLIENT_VERSION for the caller.
fetch_web_client_dist() {
  local version=$1
  local dest_dist_dir=$2

  pull_web_client_package "${version}"

  if [[ ! -d "${WEB_CLIENT_PKG_DIR}/dist/live" ]]; then
    echo "${CRISP_CLIENT_NPM_PACKAGE}@${version} ships no dist/live - it was published without a standalone build." >&2
    exit 1
  fi

  mkdir -p "${dest_dist_dir}"
  cp -R "${WEB_CLIENT_PKG_DIR}/dist/live/." "${dest_dist_dir}"
}

# Copies the published web client's per-locale JSON (src/locales) into
# <dest_locales_dir>. These are the translation sources the strings catalog is
# generated from. The built dist only carries them as hashed JS chunks.
# Sets WEB_CLIENT_VERSION for the caller.
fetch_web_client_locales() {
  local version=$1
  local dest_locales_dir=$2

  pull_web_client_package "${version}"

  if [[ ! -d "${WEB_CLIENT_PKG_DIR}/src/locales" ]]; then
    echo "${CRISP_CLIENT_NPM_PACKAGE}@${version} ships no src/locales - check the package's 'files' field." >&2
    exit 1
  fi

  mkdir -p "${dest_locales_dir}"
  cp -R "${WEB_CLIENT_PKG_DIR}/src/locales/." "${dest_locales_dir}"
}

# Paths and inputs for the generated strings catalog. Everything under the
# '_strings.sdk' group of crisp-client's per-locale JSON is ours, the rest
# belongs to the web client's own UI.
CRISP_STRINGS_CATALOG="${PWD}/Sources/CrispChatBox/Assets/Localizable.xcstrings"
CRISP_STRINGS_POLYGLOT="${PWD}/.swiftpolyglot.json"
CRISP_STRINGS_GROUP="sdk"

# Regenerates the strings catalog, and swiftpolyglot's language list alongside
# it, from the per-locale JSON in <locales_dir>. The catalog is generated rather
# than hand-edited: crisp-client owns these translations and reships them on
# every release.
write_strings_catalog() {
  local locales_dir=$1

  # -S sorts keys throughout, which is the order Xcode's catalog editor writes
  # and keeps regeneration diffs limited to real changes.
  jq -S -s --arg group "${CRISP_STRINGS_GROUP}" '
    # crisp-client writes locale codes lowercase and dash-separated (pt-br,
    # uz-cyrl, sr-cyrl-cs); Xcode expects BCP-47 casing (pt-BR, uz-Cyrl,
    # sr-Cyrl-CS). Subtags are 4 chars for a script and 2 for a region.
    def bcp47:
      split("-")
      | [.[0]] + (.[1:] | map(
          if length == 4 then (.[0:1] | ascii_upcase) + (.[1:] | ascii_downcase)
          else ascii_upcase
          end))
      | join("-");

    map(select(._strings[$group] != null)) as $locales
    | if ($locales | length) == 0 then
        error("No locale ships a '\''_strings.\($group)'\'' group. Has the group been renamed upstream?")
      else . end
    | reduce $locales[] as $locale ({};
        (($locale._meta.locale_code) | bcp47) as $code
        | reduce ($locale._strings[$group] | to_entries[]) as $string (.;
            .[$string.key] += {
              ($code): { "stringUnit": { "state": "translated", "value": $string.value } }
            }
          )
      )
    | {
        "sourceLanguage": "en",
        "strings": (
          to_entries
          | map({
              key: "\($group).\(.key)",
              # Xcode leaves manual entries alone. Without this it prunes keys it
              # cannot trace back to a source literal.
              value: { "extractionState": "manual", "localizations": .value },
            })
          | from_entries
        ),
        "version": "1.2",
      }
  ' "${locales_dir}"/*.json > "${CRISP_STRINGS_CATALOG}"

  local locales
  locales="$(jq -c '[.strings[].localizations | keys[]] | unique' "${CRISP_STRINGS_CATALOG}")"

  # swiftpolyglot only validates the languages it is told about, so a locale
  # missing from this list ships unchecked. Regenerate it from the catalog rather
  # than hand-maintaining it, or the next upstream locale arrives unvalidated.
  jq --argjson languages "${locales}" '.languages = $languages' \
    "${CRISP_STRINGS_POLYGLOT}" > "${CRISP_STRINGS_POLYGLOT}.tmp" \
    && mv "${CRISP_STRINGS_POLYGLOT}.tmp" "${CRISP_STRINGS_POLYGLOT}"

  local locale_count key_count
  locale_count="$(jq -r 'length' <<< "${locales}")"
  key_count="$(jq -r '.strings | length' "${CRISP_STRINGS_CATALOG}")"

  echo "Wrote ${CRISP_STRINGS_CATALOG#"${PWD}"/}: ${key_count} keys × ${locale_count} locales."
  echo "Wrote ${CRISP_STRINGS_POLYGLOT#"${PWD}"/}: validating ${locale_count} languages."
}

# Builds the standalone web client in <repo_path> and copies its dist into
# <dest_dist_dir>. Sets WEB_CLIENT_VERSION for the caller, with the checkout's
# short SHA as semver build metadata. A local build is not the same artifact as
# the published version it claims to be, the SHA tells them apart.
build_web_client_dist() {
  local repo_path=$1
  local dest_dist_dir=$2

  pushd "${repo_path}" > /dev/null
  npm install
  npm install --save-dev @vue/language-core
  npm run build:standalone

  WEB_CLIENT_VERSION="$(jq -r .version package.json)+$(git rev-parse --short HEAD)"
  popd > /dev/null

  mkdir -p "${dest_dist_dir}"
  cp -R "${repo_path}/dist/live/." "${dest_dist_dir}"
}

# Writes the CrispClient.swift glue (the CrispWebClient API) into <target_dir>.
# Relies on WEB_CLIENT_VERSION set by fetch_web_client_dist or
# build_web_client_dist.
write_crisp_client_swift() {
  local target_dir=$1

  cat <<EOF > "${target_dir}/CrispClient.swift"
import Foundation

// swiftlint:disable no_public_outside_crisp

public struct MissingBundleError: Error {}

public enum CrispWebClient {}

public extension CrispWebClient {
  static let version = "${WEB_CLIENT_VERSION:?}"

  static func bundleURL() throws(MissingBundleError) -> URL {
    guard let url = Bundle.module.url(forResource: "dist", withExtension: nil) else {
      throw MissingBundleError()
    }
    return url
  }
}

// swiftlint:enable no_public_outside_crisp

EOF
}
