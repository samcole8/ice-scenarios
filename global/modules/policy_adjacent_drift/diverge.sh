set -euo pipefail

BUCKET_NAME=$(terraform output -raw bucket_name 2>/dev/null || echo "")

if [ -z "$BUCKET_NAME" ]; then
    echo "Couldn't getr bucket name"
    echo "Pass it explicitly: ./diverge.sh ice-bucket"
    exit 1
fi

if [ "${1:-}" != "" ]; then
    BUCKET_NAME="$1"
fi

echo "Disabling BlockPublicAccess on $BUCKET_NAME"

aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration \
    BlockPublicAcls=false,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo "Done"