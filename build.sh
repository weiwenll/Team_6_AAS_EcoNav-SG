#!/bin/bash
set -euo pipefail

echo -e "${GREEN}Checking prerequisites...${NC}"
command -v docker >/dev/null 2>&1 || { echo -e "${RED}Docker is required but not installed.${NC}" >&2; exit 1; }
command -v sam >/dev/null 2>&1 || { echo -e "${RED}SAM CLI is required but not installed.${NC}" >&2; exit 1; }

# -----------------------------
# Pretty colors
# -----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Starting SAM build process...${NC}"

# -----------------------------
# Clean previous builds
# -----------------------------
echo -e "${YELLOW}Cleaning previous builds...${NC}"
rm -rf .aws-sam

# Defensive cleanup of any partial site-packages from earlier failed runs
find layers -maxdepth 3 -type d -name "__pycache__" -prune -exec rm -rf {} + || true

# Ensure layer python dirs exist
mkdir -p layers/crewai/python layers/nemo/python layers/common/python

# -----------------------------
# Build layers (hardened pip in Docker)
# -----------------------------
echo -e "${YELLOW}Building layers...${NC}"

# ---- CrewAI layer (uses LC 0.2.x band, no crewai-tools) ----
docker run --rm --network host -v "$PWD":/var/task public.ecr.aws/sam/build-python3.11:latest \
  /bin/bash -lc '
    set -euo pipefail
    python -m pip install --upgrade pip &&
    pip cache purge || true &&
    PIP_NO_CACHE_DIR=1 pip install \
      --retries 8 --timeout 120 --prefer-binary -i https://pypi.org/simple \
      -r layers/crewai/requirements.txt -t layers/crewai/python/
  '

# After each layer build, add:
if [ ! -d "layers/crewai/python" ] || [ -z "$(ls -A layers/crewai/python)" ]; then
    echo -e "${RED}Failed to build CrewAI layer${NC}"
    exit 1
fi

# ---- NeMo layer (pins LC 0.1.x compatible with nemoguardrails 0.7.0) ----
docker run --rm --network host -v "$PWD":/var/task public.ecr.aws/sam/build-python3.11:latest \
  /bin/bash -lc '
    set -euo pipefail
    python -m pip install --upgrade pip &&
    pip cache purge || true &&
    PIP_NO_CACHE_DIR=1 pip install \
      --retries 8 --timeout 120 --prefer-binary -i https://pypi.org/simple \
      -r layers/nemo/requirements.txt -t layers/nemo/python/
  '

# After each layer build, add:
if [ ! -d "layers/nemo/python" ] || [ -z "$(ls -A layers/nemo/python)" ]; then
    echo -e "${RED}Failed to build nemo layer${NC}"
    exit 1
fi

# ---- Common layer ----
docker run --rm --network host -v "$PWD":/var/task public.ecr.aws/sam/build-python3.11:latest \
  /bin/bash -lc '
    set -euo pipefail
    python -m pip install --upgrade pip &&
    pip cache purge || true &&
    PIP_NO_CACHE_DIR=1 pip install \
      --retries 8 --timeout 120 --prefer-binary -i https://pypi.org/simple \
      -r layers/common/requirements.txt -t layers/common/python/
  '

# After each layer build, add:
if [ ! -d "layers/common/python" ] || [ -z "$(ls -A layers/common/python)" ]; then
    echo -e "${RED}Failed to build common layer${NC}"
    exit 1
fi

# -----------------------------
# Swap in lambda-specific requirements for each service
# (temporary copy during build; restored after)
# -----------------------------
echo -e "${YELLOW}Preparing service requirements...${NC}"

cp api-gateway/requirements-lambda.txt api-gateway/requirements.txt.bak
cp api-gateway/requirements-lambda.txt api-gateway/requirements.txt

cp intent-requirements-service/requirements-lambda.txt intent-requirements-service/requirements.txt.bak
cp intent-requirements-service/requirements-lambda.txt intent-requirements-service/requirements.txt

cp shared-services/requirements-lambda.txt shared-services/requirements.txt.bak
cp shared-services/requirements-lambda.txt shared-services/requirements.txt

# -----------------------------
# Build SAM application
# -----------------------------
echo -e "${YELLOW}Building SAM application...${NC}"
sam build --use-container --parallel

# -----------------------------
# Restore original requirements
# -----------------------------
mv api-gateway/requirements.txt.bak api-gateway/requirements.txt
mv intent-requirements-service/requirements.txt.bak intent-requirements-service/requirements.txt
mv shared-services/requirements.txt.bak shared-services/requirements.txt

echo -e "${GREEN}Build complete!${NC}"
