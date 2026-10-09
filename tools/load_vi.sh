#!/usr/bin/env bash
# AUTHOR TOOL: create "chonhata_vi" — the same data with Vietnamese text values,
# used to fill query results in the Vietnamese edition (manuscript/).
exec bash "$(dirname "$0")/load_big.sh" 1 chonhata_vi vi
