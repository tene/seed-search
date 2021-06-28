#!/usr/bin/env bash
if [ "$#" -ne 0 ] ; then
    SEED="$1"
else
    SEED=1
fi

if [ -z "$CRAWL_PATH" ] ; then
    CRAWL_PATH=../crawl
fi

"$CRAWL_PATH"/crawl-ref/source/util/fake_pty "$CRAWL_PATH"/crawl-ref/source/crawl -script scrape-seed.lua "$SEED"