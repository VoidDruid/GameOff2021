#!/usr/bin/env bash
set -e

function get_disjointed_translations() {
    # TODO: awk script to parse csv translation files
    awk '' $1/requirements.txt | xargs echo
}
