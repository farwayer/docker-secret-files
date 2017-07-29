#!/bin/sh
set -e

DEFAULT_IMAGE=secret
DEFAULT_OUTDIR=dsecret

function usage() {
  printf "
Usage:
  $0 -c [-i image-name] [-p] pAssW0rd
  $0 -d [-i image-name] [-o out-secret] pAssW0rd

  -c: create image
  -d: decrypt and get out secret files
  -i: image name ('$DEFAULT_IMAGE' is default)
  -o: output dir ('$DEFAULT_OUTDIR' is default)
  -p: push image
"
  exit 1
}

while getopts 'i:o:cdp' OPTION; do
  case ${OPTION} in
    c) CREATING=1 ;;
    d) DECRYPTING=1 ;;
    i) IMAGE="$OPTARG"; ;;
    o) OUTDIR="$OPTARG" ;;
    p) PUSH=1 ;;
    :|\?) usage ;;
  esac
done

shift $((OPTIND-1))
PASSWORD=$1

if [ $((CREATING ^ DECRYPTING)) = 0 ] ; then usage; fi
if [ -z "$PASSWORD" ]; then usage; fi
if [ -z "$IMAGE" ]; then IMAGE="$DEFAULT_IMAGE"; fi
if [ -z "$OUTDIR" ]; then OUTDIR="$DEFAULT_OUTDIR"; fi

if [ ${CREATING} ]; then
  printf "Creating '$IMAGE' image...\n"
  docker build --squash --compress --tag "$IMAGE" --build-arg password="$PASSWORD" .
  (($PUSH)) && docker push "$IMAGE"
else
  output=$(realpath "$OUTDIR")
  printf "Use '$IMAGE' image\n"
  printf "Decrypting secret files to $output...\n"
  docker run --rm -v "$output":/dsecret "$IMAGE" decrypt /dsecret "$PASSWORD"
fi
