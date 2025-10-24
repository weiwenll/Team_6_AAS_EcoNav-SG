#!/bin/bash
set -e

echo "🧪 Testing Local Deployment..."

API_URL="http://localhost:8000"

# Test 1: Health Check
echo -e "\n✅ Test 1: Health Check"
curl -s "$API_URL/health" | jq '.'

# Test 2: Greeting
echo -e "\n✅ Test 2: Greeting Intent"
RESPONSE=$(curl -s -X POST "$API_URL/travel/plan" \
  -H "Content-Type: application/json" \
  -d '{
    "user_input": "Hello!",
    "session_id": null
  }')

echo "$RESPONSE" | jq '.'
SESSION_ID=$(echo "$RESPONSE" | jq -r '.session_id')
echo "Session ID: $SESSION_ID"

# Test 3: Planning Intent - Provide all required information
echo -e "\n✅ Test 3: Planning Intent (Complete Info)"
curl -s -X POST "$API_URL/travel/plan" \
  -H "Content-Type: application/json" \
  -d '{
    "user_input": "I want to visit Singapore from December 20 to December 25, 2025 with a budget of 2000 SGD. I prefer a relaxed pace.",
    "session_id": "'$SESSION_ID'"
  }' | jq '.'

# Test 4: Continue conversation with more details
echo -e "\n✅ Test 4: Add More Details"
curl -s -X POST "$API_URL/travel/plan" \
  -H "Content-Type: application/json" \
  -d '{
    "user_input": "I am interested in gardens and museums, and I prefer vegetarian food",
    "session_id": "'$SESSION_ID'"
  }' | jq '.'

# Test 5: Session Info
echo -e "\n✅ Test 5: Session Info"
curl -s "$API_URL/travel/session/$SESSION_ID" | jq '.'

# Test 6: Verify S3 Storage (LocalStack)
echo -e "\n✅ Test 6: LocalStack S3 Storage Verification"
echo "Sessions in S3:"
aws --endpoint-url=http://localhost:4566 s3 ls s3://stp-state-local/dev/sessions/

echo -e "\nRequirements in S3:"
aws --endpoint-url=http://localhost:4566 s3 ls s3://stp-state-local/dev/requirements/

# Test 7: Read session data from S3
echo -e "\n✅ Test 7: Read Session Data from S3"
echo "Session data:"
aws --endpoint-url=http://localhost:4566 s3 cp s3://stp-state-local/dev/sessions/${SESSION_ID}.json - | jq '.'

echo -e "\nRequirements data:"
aws --endpoint-url=http://localhost:4566 s3 cp s3://stp-state-local/dev/requirements/${SESSION_ID}.json - | jq '.'

echo -e "\n🎉 All local tests passed!"