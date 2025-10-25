#!/bin/bash
set -euo pipefail

# Configuration
export SAM_CLI_TELEMETRY=0
export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0

STACK_NAME="travel-planner-stack"
REGION="${AWS_REGION:-ap-southeast-2}"
OPENAI_KEY="${OPENAI_KEY:-}"
OWNER="${STACK_OWNER:-$(whoami)}"
AWS_PROFILE="${AWS_PROFILE:-default}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🚀 Deploying Travel Planner Stack${NC}"

# Validate OpenAI Key
if [ -z "$OPENAI_KEY" ]; then
    echo -e "${RED}❌ OPENAI_KEY environment variable not set${NC}"
    exit 1
fi

# Generate bucket name
BUCKET_NAME="stp-state-${OWNER}-${REGION}-$(date +%Y%m%d)"
echo -e "${YELLOW}   S3 Bucket: $BUCKET_NAME${NC}"

# Clean
echo -e "${YELLOW}📦 Cleaning previous builds...${NC}"
rm -rf .aws-sam

# Build
echo -e "${YELLOW}📦 Building container images...${NC}"
sam build --use-container --parallel

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

# Deploy
echo -e "${YELLOW}🚀 Deploying to AWS...${NC}"

sam deploy \
  --template-file .aws-sam/build/template.yaml \
  --stack-name "$STACK_NAME" \
  --capabilities CAPABILITY_IAM \
  --region "$REGION" \
  --resolve-s3 \
  --resolve-image-repos \
  --parameter-overrides \
    OpenAIKey="$OPENAI_KEY" \
    ModelName=gpt-4o-mini \
    StateBucketName="$BUCKET_NAME" \
    StateBasePrefix=prod \
  --no-confirm-changeset \
  --no-fail-on-empty-changeset \
  --profile "$AWS_PROFILE"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Deployment failed${NC}"
    exit 1
fi

# Get API URL
echo ""
echo -e "${YELLOW}📍 Getting API URL...${NC}"

API_URL=$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --region "$REGION" \
  --query 'Stacks[0].Outputs[?OutputKey==`ApiUrl`].OutputValue' \
  --output text \
  --profile "$AWS_PROFILE" 2>/dev/null || echo "")

if [ -n "$API_URL" ]; then
    echo -e "${GREEN}✅ Deployment complete!${NC}"
    echo -e "${GREEN}🌐 API URL: $API_URL${NC}"
    echo ""
    echo -e "${YELLOW}Test your deployment:${NC}"
    echo "  curl $API_URL/health"
else
    echo -e "${YELLOW}⚠️  Could not retrieve API URL${NC}"
fi