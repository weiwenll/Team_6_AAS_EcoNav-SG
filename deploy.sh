#!/bin/bash
set -euo pipefail

STACK_NAME="travel-planner-stack"
REGION="ap-southeast-2"
OPENAI_KEY="${OPENAI_KEY:-REPLACE_ME}"
OWNER="${STACK_OWNER:-default}"
AWS_PROFILE="${AWS_PROFILE:-default}"

echo "🚀 Deploying Travel Planner Stack..."
echo "   Stack: $STACK_NAME"
echo "   Region: $REGION"
echo "   Owner: $OWNER"
echo "   AWS Profile: $AWS_PROFILE"

# Generate unique bucket name
BUCKET_NAME="stp-state-${OWNER}-${REGION}-$(date +%Y%m%d%H%M%S)"
echo "   S3 Bucket: $BUCKET_NAME"

# Let SAM manage the artifacts bucket automatically
sam deploy \
  --template-file template.yaml \
  --stack-name "$STACK_NAME" \
  --capabilities CAPABILITY_IAM \
  --region "$REGION" \
  --resolve-s3 \
  --parameter-overrides \
    OpenAIKey="$OPENAI_KEY" \
    ModelName=gpt-4o-mini \
    StateBucketName="$BUCKET_NAME" \
    StateBasePrefix=prod \
  --no-confirm-changeset \
  --profile "$AWS_PROFILE"

echo ""
echo "✅ Deployment complete!"
echo ""
echo "To get your API URL, run:"
echo "  aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION --query 'Stacks[0].Outputs[?OutputKey==\`ApiUrl\`].OutputValue' --output text --profile $AWS_PROFILE"