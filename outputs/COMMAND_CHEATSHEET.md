# Testing Command Cheatsheet

## 🚀 Essential Commands

### Setup (One-time)
```bash
# Install dependencies
pip install -r requirements-test.txt

# Make test script executable
chmod +x run-tests.sh
```

---

## 🧪 Running Tests

### Basic Test Execution
```bash
# Run all tests (recommended)
./run-tests.sh

# Run all tests with pytest directly
pytest tests/ -v

# Run all tests with coverage
pytest tests/ --cov=. --cov-report=html

# Run tests and open coverage report
pytest tests/ --cov=. --cov-report=html && open htmlcov/index.html
```

### By Test Category
```bash
# Unit tests only
pytest tests/ -v -m "unit"

# Security tests only
pytest tests/ -v -m "security"

# Integration tests only
pytest tests/ -v -m "integration"

# Slow tests
pytest tests/ -v -m "slow"
```

### By Test File
```bash
# Intent classification tests
pytest tests/test_intent_classification.py -v

# Requirements gathering tests
pytest tests/test_requirements_gathering.py -v

# Security tests
pytest tests/test_security.py -v

# Session management tests
pytest tests/test_session_management.py -v

# API gateway tests
pytest tests/test_api_gateway.py -v
```

### By Test Name
```bash
# Run specific test class
pytest tests/test_security.py::TestSecurityPipeline -v

# Run specific test method
pytest tests/test_security.py::TestSecurityPipeline::test_validate_malicious_input -v

# Run tests matching pattern
pytest tests/ -k "classification" -v
pytest tests/ -k "security" -v
pytest tests/ -k "session" -v
```

---

## 🔍 Debugging & Investigation

### Verbose Output
```bash
# Extra verbose
pytest tests/ -vv

# Show print statements
pytest tests/ -v -s

# Show local variables on failure
pytest tests/ -v -l

# Full traceback
pytest tests/ -v --tb=long

# Short traceback (default)
pytest tests/ -v --tb=short

# Only show failed test names
pytest tests/ -v --tb=no
```

### Interactive Debugging
```bash
# Drop into debugger on failure
pytest tests/ --pdb

# Drop into debugger on error
pytest tests/ --pdb --pdbcls=IPython.terminal.debugger:TerminalPdb

# Run until first failure, then debug
pytest tests/ -x --pdb
```

### Selective Execution
```bash
# Stop at first failure
pytest tests/ -x

# Stop after N failures
pytest tests/ --maxfail=3

# Run last failed tests only
pytest tests/ --lf

# Run failed tests first, then others
pytest tests/ --ff

# Run new tests first
pytest tests/ --nf
```

---

## 📊 Coverage Commands

### Generate Coverage Reports
```bash
# Terminal report only
pytest tests/ --cov=. --cov-report=term

# Terminal with missing lines
pytest tests/ --cov=. --cov-report=term-missing

# HTML report
pytest tests/ --cov=. --cov-report=html

# XML report (for CI/CD)
pytest tests/ --cov=. --cov-report=xml

# All reports
pytest tests/ --cov=. --cov-report=term-missing --cov-report=html --cov-report=xml
```

### View Coverage
```bash
# Open HTML report (Mac)
open htmlcov/index.html

# Open HTML report (Linux)
xdg-open htmlcov/index.html

# View specific file coverage
coverage report -m --include="api-gateway/main.py"
```

### Coverage by Component
```bash
# Coverage for specific module
pytest tests/ --cov=api-gateway --cov-report=term-missing

# Coverage for intent service
pytest tests/ --cov=intent-requirements-service --cov-report=term-missing

# Coverage for shared services
pytest tests/ --cov=shared-services --cov-report=term-missing
```

---

## 🏃 Performance & Timing

### Timing Information
```bash
# Show slowest 10 tests
pytest tests/ --durations=10

# Show slowest 20 tests
pytest tests/ --durations=20

# Show all test durations
pytest tests/ --durations=0
```

### Parallel Execution
```bash
# Install pytest-xdist first
pip install pytest-xdist

# Run tests in parallel (4 workers)
pytest tests/ -n 4

# Auto-detect number of CPUs
pytest tests/ -n auto
```

---

## 🔧 Environment Control

### Set Environment Variables
```bash
# Run with custom environment
OPENAI_API_KEY="test-123" USE_S3="false" pytest tests/ -v

# Run with staging config
ENVIRONMENT="staging" pytest tests/ -v

# Disable guardrails
GUARDRAILS_ENABLED="false" pytest tests/ -v
```

### Using .env Files
```bash
# Create test.env
cat > test.env << EOF
OPENAI_API_KEY=test-key-12345
USE_S3=false
GUARDRAILS_ENABLED=false
AWS_REGION=ap-southeast-1
EOF

# Load and run
export $(cat test.env | xargs) && pytest tests/ -v
```

---

## 📝 Test Creation & Maintenance

### Create New Test File
```bash
# Copy template
cat > tests/test_new_feature.py << 'EOF'
import pytest
from unittest.mock import Mock, patch

@pytest.mark.unit
class TestNewFeature:
    def test_basic_functionality(self):
        """Test description"""
        # Arrange
        expected = "expected"
        
        # Act
        result = function_to_test()
        
        # Assert
        assert result == expected
EOF
```

### Validate Test Syntax
```bash
# Check for syntax errors
python -m py_compile tests/test_new_feature.py

# Lint tests
flake8 tests/

# Format tests
black tests/
isort tests/
```

---

## 🔄 CI/CD Commands

### Local CI Simulation
```bash
# Run full CI pipeline locally
./run-tests.sh && \
pytest tests/ -m "security" && \
flake8 . && \
black --check . && \
docker build -f Dockerfile.api-gateway .
```

### GitHub Actions
```bash
# Trigger workflow manually
gh workflow run ci-cd.yml

# View workflow status
gh workflow view

# View latest run
gh run list --limit 1

# View logs
gh run view --log
```

---

## 🎯 Common Workflows

### Pre-commit Checks
```bash
# Run before committing
pytest tests/ -v --tb=short && git commit -m "Your message"
```

### Pre-push Checks
```bash
# Run before pushing
./run-tests.sh && \
pytest tests/ -m "security" && \
flake8 . && \
git push
```

### Daily Development
```bash
# Fast feedback loop
pytest tests/test_intent_classification.py -v

# After changes to security
pytest tests/test_security.py -v --cov=shared-services/security_pipeline.py

# After changes to requirements gathering
pytest tests/test_requirements_gathering.py -v
```

### Weekly Review
```bash
# Full test suite with coverage
./run-tests.sh

# Review coverage
open htmlcov/index.html

# Check for slow tests
pytest tests/ --durations=20

# Security audit
pytest tests/ -m "security" -v
```

---

## 🆘 Troubleshooting Commands

### Clear Cache
```bash
# Remove pytest cache
rm -rf .pytest_cache

# Remove Python cache
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null

# Remove coverage data
rm -rf .coverage htmlcov/ coverage.xml
```

### Reset Environment
```bash
# Deactivate virtual environment
deactivate

# Remove virtual environment
rm -rf venv

# Recreate and reinstall
python3 -m venv venv
source venv/bin/activate
pip install -r requirements-test.txt
```

### Verify Installation
```bash
# Check pytest version
pytest --version

# List installed plugins
pytest --co

# Show configuration
pytest --showlocals
```

---

## 📦 Installation Shortcuts

### Quick Install (All Dependencies)
```bash
pip install pytest pytest-asyncio pytest-cov pytest-mock pytest-env \
            httpx fastapi python-dotenv responses moto faker
```

### Minimal Install (Core Only)
```bash
pip install pytest pytest-asyncio pytest-cov
```

---

## 🎓 Learning & Documentation

### Show Help
```bash
# General help
pytest --help

# Coverage help
pytest --help | grep cov

# Markers help
pytest --markers
```

### List Tests
```bash
# List all tests (don't run)
pytest tests/ --collect-only

# Count tests
pytest tests/ --collect-only -q | wc -l

# List by marker
pytest tests/ --collect-only -m "security"
```

---

## 💾 Output & Reporting

### Save Test Results
```bash
# Save to file
pytest tests/ -v > test_results.txt

# JUnit XML (for CI/CD)
pytest tests/ --junit-xml=test_results.xml

# JSON report
pip install pytest-json-report
pytest tests/ --json-report --json-report-file=report.json
```

### Watch Mode
```bash
# Install pytest-watch
pip install pytest-watch

# Auto-run tests on file change
ptw tests/
```

---

## ✅ Copy-Paste Ready Commands

### Most Common Commands (Copy These!)

```bash
# Run all tests with coverage
pytest tests/ -v --cov=. --cov-report=html

# Run and open coverage report
pytest tests/ --cov=. --cov-report=html && open htmlcov/index.html

# Run single test file
pytest tests/test_security.py -v

# Run security tests only
pytest tests/ -v -m "security"

# Debug failed test
pytest tests/test_security.py::TestSecurityPipeline::test_validate_malicious_input -vv --pdb

# Show slowest tests
pytest tests/ --durations=10

# Run tests matching pattern
pytest tests/ -k "security" -v

# Stop at first failure
pytest tests/ -x

# Run last failed tests
pytest tests/ --lf
```

---

**Save this file for quick reference!** 📌
