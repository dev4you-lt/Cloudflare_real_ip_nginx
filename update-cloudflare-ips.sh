#!/bin/bash

set -e

CLOUDFLARE_CONF_PATH="/etc/nginx/cf.conf"

CF_BASEURL="https://www.cloudflare.com/"
CF_IP4="$CF_BASEURL/ips-v4"
CF_IP6="$CF_BASEURL/ips-v6"

CF_IP4_MIN_COUNT=4
CF_IP6_MIN_COUNT=2

TEMP_FILE="$(mktemp /tmp/nginx_cf_XXXXXXX.conf)"

die() {
    echo "$1" >&2
    exit 1
}

warn() {
    echo "Warning: $1" >&2
}

fetch() {
    local url="$1"

    if ! curl -s -L "$1"
    then
        die "Error fetching URL $url"
    fi
}

validate_ip() {
    validate_ip4 "$1" || validate_ip6 "$1"
}

validate_ip6() {
    [[ "$1" =~ ^[0-9a-fA-F/:]+$ ]]
}

validate_ip4() {
    [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]
}

readarray -t ipv4 < <(fetch "$CF_IP4")
readarray -t ipv6 < <(fetch "$CF_IP6")

if [[ "${#ipv4[@]}" -lt "$CF_IP4_MIN_COUNT" ]]
then
    warn "too few IPv4 addresses. Might be an error at CF endpoint."
fi

if [[ "${#ipv6[@]}" -lt "$CF_IP6_MIN_COUNT" ]]
then
    warn "too few IPv6 addresses. Might be an error at CF endpoint."
fi

{
    echo "# Cloudflare IP addresses"
    echo ""

    for ip in "${ipv4[@]}" "" "${ipv6[@]}" ""
    do
        [[ -z "$ip" ]] && echo && continue
        if ! validate_ip "$ip"
        then
           warn "$ip doesn't look like a valid IP. Skipping."
           continue
        fi
        echo "set_real_ip_from $ip;"
    done

    echo "real_ip_header CF-Connecting-IP;"
} > "$TEMP_FILE"

if ! mv "$TEMP_FILE" "$CLOUDFLARE_CONF_PATH"
then
    die "Unable to rename the config file."
fi

if ! nginx -t
then
    die "Invalid syntax."
fi

systemctl reload nginx
