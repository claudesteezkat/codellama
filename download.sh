#!/bin/bash

# Copyright (c) Meta Platforms, Inc. and affiliates.
# This software may be used and distributed according to the terms of the Llama 2 Community License Agreement.

read -p "https://download2.llamameta.net/*?Policy=eyJTdGF0ZW1lbnQiOlt7InVuaXF1ZV9oYXNoIjoieXN0Y2YzaHcxa3UzZDR4NzQ2YXhpYWZoIiwiUmVzb3VyY2UiOiJodHRwczpcL1wvZG93bmxvYWQyLmxsYW1hbWV0YS5uZXRcLyoiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2OTMyMDU1OTF9fX1dfQ__&Signature=FNqMs6LaeBOFFHNzpdt6Bn9IV%7EXcdKle46FW50iqHtHf7dFYD-pe6fkPHNGGEa3e25yySr86k62z%7E0UXAsPqNoDdVl7%7Ee%7EFnkIwWLXFENTiFna%7ElnIrj0lh7lO864oFfjP5t-8v2v79JQ9wHAKb7sI6Vufzm3hVId25BGqe3kUGteMMhw5EVINCKuO5lmibbsSS%7E3jNhpAmNnbksqoBH8exOHmNKQ%7EOSJFqv-xZDa-IGrxJRvr6tjISLiSx%7EzR6X2zV1qUyt4fL3PWgxVVsk9wNqcI59-oiu18CDfr-f5hLrUkSj8fX8vTgAni4iJQ-yy648jPbuh4%7EKfJiiCA1Wfw__&Key-Pair-Id=K15QRJLYKIFSLZ&Download-Request-ID=309022791663015: " PRESIGNED_URL
echo ""
ALL_MODELS="7b-Python,7b-Instruct"
read -p "Enter the list of models to download without spaces ($ALL_MODELS), or press Enter for all: " MODEL_SIZE
TARGET_FOLDER="."             # where all files should end up
mkdir -p ${TARGET_FOLDER}

if [[ $MODEL_SIZE == "" ]]; then
    MODEL_SIZE=$ALL_MODELS
fi

echo "Downloading LICENSE and Acceptable Usage Policy"
wget ${PRESIGNED_URL/'*'/"LICENSE"} -O ${TARGET_FOLDER}"/LICENSE"
wget ${PRESIGNED_URL/'*'/"USE_POLICY.md"} -O ${TARGET_FOLDER}"/USE_POLICY.md"

for m in ${MODEL_SIZE//,/ }
do
    case $m in
      7b)
        SHARD=0 ;;
      13b)
        SHARD=1 ;;
      34b)
        SHARD=3 ;;
      7b-Python)
        SHARD=0 ;;
      13b-Python)
        SHARD=1 ;;
      34b-Python)
        SHARD=3 ;;
      7b-Instruct)
        SHARD=0 ;;
      13b-Instruct)
        SHARD=1 ;;
      34b-Instruct)
        SHARD=3 ;;
      *)
        echo "Unknown model: $m"
        exit 1
    esac

    MODEL_PATH="CodeLlama-$m"
    echo "Downloading ${MODEL_PATH}"
    mkdir -p ${TARGET_FOLDER}"/${MODEL_PATH}"

    for s in $(seq -f "0%g" 0 ${SHARD})
    do
        wget ${PRESIGNED_URL/'*'/"${MODEL_PATH}/consolidated.${s}.pth"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/consolidated.${s}.pth"
    done

    wget ${PRESIGNED_URL/'*'/"${MODEL_PATH}/params.json"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/params.json"
    wget ${PRESIGNED_URL/'*'/"${MODEL_PATH}/tokenizer.model"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/tokenizer.model"
    wget ${PRESIGNED_URL/'*'/"${MODEL_PATH}/checklist.chk"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/checklist.chk"
    echo "Checking checksums"
    (cd ${TARGET_FOLDER}"/${MODEL_PATH}" && md5sum -c checklist.chk)
done
