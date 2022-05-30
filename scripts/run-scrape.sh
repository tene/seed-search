#!/usr/bin/env bash
if [ "$#" -ne 0 ] ; then
    SEED="$1"
else
    SEED=1
fi

if [ -z "$CRAWL_PATH" ] ; then
    CRAWL_PATH=../crawl
fi
mkdir -p cache
cache="cache/seed-${SEED}.jsonl.gz"
if [ ! -f "$cache" ] ; then
    TMP="$(mktemp $cache.XXXXXX.tmp)"
    cp -f scripts/scrape-seed.lua "$CRAWL_PATH"/crawl-ref/source/scripts/scrape-seed.lua 2>&1 >/dev/null
    if "$CRAWL_PATH"/crawl-ref/source/util/fake_pty "$CRAWL_PATH"/crawl-ref/source/crawl -script scrape-seed.lua "$SEED" 2>&1 | sed '/^$/d' | gzip > "$TMP" ; then
        mv "$TMP" "cache"
    else
        mkdir -p cache/errors
        mv "$TMP" cache/errors
    fi
fi

gzip -d < "$cache"
