#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}  Running Unit Tests${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo -e "${YELLOW}Creating virtual environment...${NC}"
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install test dependencies
echo -e "${YELLOW}Installing test dependencies...${NC}"
pip install -q -r requirements-test.txt

# Set environment variables for testing
export PYTHONPATH="${PYTHONPATH}:$(pwd)"
export OPENAI_API_KEY="test-key-12345"
export AWS_REGION="ap-southeast-1"
export USE_S3="false"
export GUARDRAILS_ENABLED="false"
export DOWNSTREAM_MODE="HTTP"

echo ""
echo -e "${GREEN}Running pytest...${NC}"
echo ""

# Run pytest with coverage
pytest tests/ \
    -v \
    --tb=short \
    --cov=. \
    --cov-report=term-missing \
    --cov-report=html \
    --cov-report=xml \
    -m "unit" \
    "$@"

TEST_EXIT_CODE=$?

echo ""
echo -e "${GREEN}================================${NC}"
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}  ✅ All tests passed!${NC}"
else
    echo -e "${RED}  ❌ Tests failed!${NC}"
fi
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${YELLOW}Coverage report generated:${NC}"
echo "  - HTML: htmlcov/index.html"
echo "  - XML: coverage.xml"
echo ""

# Optional: Run specific test categories
if [ "$1" == "security" ]; then
    echo -e "${GREEN}Running security tests...${NC}"
    pytest tests/ -v -m "security"
fi

if [ "$1" == "integration" ]; then
    echo -e "${GREEN}Running integration tests...${NC}"
    pytest tests/ -v -m "integration"
fi

exit $TEST_EXIT_CODE
