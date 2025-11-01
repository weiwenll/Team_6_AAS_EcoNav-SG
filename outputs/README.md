# Testing Documentation

## Overview

This directory contains comprehensive unit tests, integration tests, and security tests for the Sustainable Travel Planner system.

## Test Structure

```
tests/
├── conftest.py                      # Pytest fixtures and configuration
├── test_intent_classification.py   # Intent classification tests
├── test_requirements_gathering.py  # Requirements gathering tests
├── test_security.py                # Security validation tests
├── test_session_management.py      # Session and storage tests
└── test_api_gateway.py             # API gateway and integration tests
```

## Setup

### Install Test Dependencies

```bash
pip install -r requirements-test.txt
```

### Environment Variables

The following environment variables are automatically set for testing:

```bash
OPENAI_API_KEY=test-key-12345
AWS_REGION=ap-southeast-1
USE_S3=false
GUARDRAILS_ENABLED=false
DOWNSTREAM_MODE=HTTP
OPENAI_MODEL_NAME=gpt-4o-mini
MAX_TOKENS=300
```

## Running Tests

### Run All Unit Tests

```bash
./run-tests.sh
```

Or with pytest directly:

```bash
pytest tests/ -v -m "unit"
```

### Run Specific Test Categories

**Security tests only:**
```bash
pytest tests/ -v -m "security"
```

**Integration tests only:**
```bash
pytest tests/ -v -m "integration"
```

**Slow tests (excluded by default):**
```bash
pytest tests/ -v -m "slow"
```

### Run Specific Test Files

```bash
pytest tests/test_intent_classification.py -v
pytest tests/test_security.py -v
```

### Run with Coverage

```bash
pytest tests/ --cov=. --cov-report=html --cov-report=term-missing
```

View coverage report:
```bash
open htmlcov/index.html
```

## Test Categories

### 1. Intent Classification Tests (`test_intent_classification.py`)

**Coverage:**
- ✅ Greeting classification
- ✅ Planning classification
- ✅ Off-topic classification
- ✅ Fallback classification when LLM fails
- ✅ Empty and long input handling
- ✅ API endpoint validation

**Key Test Cases:**
```python
async def test_greeting_classification()
async def test_planning_classification()
async def test_fallback_classification_greeting()
def test_classify_intent_endpoint_success()
```

### 2. Requirements Gathering Tests (`test_requirements_gathering.py`)

**Coverage:**
- ✅ Greeting to planning transition
- ✅ Complete information extraction
- ✅ Partial information extraction
- ✅ Off-topic handling
- ✅ Completion detection (mandatory + optional)
- ✅ Interest extraction
- ✅ Session persistence

**Key Test Cases:**
```python
async def test_extract_complete_planning_info()
async def test_check_completion_all_complete()
async def test_interests_extraction()
def test_gather_requirements_endpoint_success()
```

### 3. Security Tests (`test_security.py`)

**Coverage:**
- ✅ Safe input validation
- ✅ Malicious input detection
- ✅ Sensitive data detection
- ✅ OpenAI Moderation API integration
- ✅ Travel context validation
- ✅ Prompt injection detection
- ✅ Timeout handling

**Key Test Cases:**
```python
async def test_validate_malicious_input()
async def test_openai_moderation_flagged()
async def test_prompt_injection_detection()
async def test_pii_detection_in_output()
```

### 4. Session Management Tests (`test_session_management.py`)

**Coverage:**
- ✅ Session creation
- ✅ Session retrieval
- ✅ Session updates
- ✅ S3 storage operations
- ✅ Memory store operations
- ✅ Trust score calculation
- ✅ Transparency reporting

**Key Test Cases:**
```python
def test_create_session()
def test_update_session()
def test_put_session_s3()
def test_calculate_trust_score()
```

### 5. API Gateway Tests (`test_api_gateway.py`)

**Coverage:**
- ✅ New session creation
- ✅ Existing session handling
- ✅ Blocked input handling
- ✅ Complete requirements flow
- ✅ Final JSON generation
- ✅ Service client operations
- ✅ End-to-end conversation flow

**Key Test Cases:**
```python
async def test_process_input_new_session()
async def test_process_input_complete_requirements()
async def test_complete_conversation_flow()
def test_build_final_json_complete()
```

## Test Coverage Goals

| Component | Current Coverage | Target |
|-----------|-----------------|---------|
| Intent Classification | ~85% | 90% |
| Requirements Gathering | ~80% | 90% |
| Security Pipeline | ~90% | 95% |
| Session Management | ~75% | 85% |
| API Gateway | ~80% | 90% |
| **Overall** | **~80%** | **90%** |

## Mocking Strategy

### External Services Mocked:
- ✅ OpenAI API (LLM calls)
- ✅ OpenAI Moderation API
- ✅ AWS S3
- ✅ AWS Lambda
- ✅ CrewAI agent execution
- ✅ HTTP requests

### Real Components Tested:
- ✅ Business logic
- ✅ Data validation
- ✅ Error handling
- ✅ State management
- ✅ API routing

## Fixtures

### Available Fixtures (from `conftest.py`):

```python
sample_session_id              # Test session ID
sample_user_input              # Various user input samples
sample_requirements            # Complete requirements structure
incomplete_requirements        # Partial requirements
mandatory_complete_requirements # Only mandatory fields filled
sample_session_data            # Session data structure
sample_conversation_history    # Conversation history
mock_openai_response           # Mocked OpenAI response
mock_moderation_response       # Mocked moderation response
mock_s3_client                 # Mocked S3 client
mock_lambda_client             # Mocked Lambda client
```

## CI/CD Integration

Tests are automatically run via GitHub Actions on:
- ✅ Pull requests
- ✅ Push to `main` branch
- ✅ Push to `develop` branch

Pipeline stages:
1. **Test** - Run all unit tests
2. **Security Tests** - Run security-specific tests
3. **Lint** - Code quality checks
4. **Build** - Build Docker images
5. **Deploy** - Deploy to staging/production

## Writing New Tests

### Template for New Test File:

```python
# tests/test_new_feature.py
import pytest
from unittest.mock import Mock, patch
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'service-name'))

@pytest.mark.unit
class TestNewFeature:
    """Test description"""
    
    def test_basic_functionality(self, sample_fixture):
        """Test case description"""
        # Arrange
        expected = "expected_value"
        
        # Act
        result = function_to_test()
        
        # Assert
        assert result == expected
    
    @pytest.mark.asyncio
    async def test_async_functionality(self):
        """Async test case"""
        result = await async_function()
        assert result is not None
```

### Best Practices:

1. **Use descriptive test names**: `test_intent_classification_with_greeting`
2. **Follow AAA pattern**: Arrange, Act, Assert
3. **Mock external dependencies**: OpenAI, S3, etc.
4. **Test edge cases**: Empty inputs, very long inputs, malicious inputs
5. **Use fixtures**: Reuse common test data
6. **Add markers**: `@pytest.mark.unit`, `@pytest.mark.security`
7. **Document intent**: Use docstrings

## Debugging Failed Tests

### Run with verbose output:
```bash
pytest tests/ -vv
```

### Run specific test:
```bash
pytest tests/test_security.py::TestSecurityPipeline::test_validate_malicious_input -v
```

### Print captured output:
```bash
pytest tests/ -v -s
```

### Drop into debugger on failure:
```bash
pytest tests/ --pdb
```

### Show local variables on failure:
```bash
pytest tests/ -l
```

## Performance Tests

While not included by default, performance tests can be added:

```python
@pytest.mark.slow
def test_performance_under_load():
    """Test system performance under load"""
    import time
    start = time.time()
    
    # Run 100 requests
    for i in range(100):
        result = process_request()
    
    elapsed = time.time() - start
    assert elapsed < 10.0  # Should complete in 10 seconds
```

Run with:
```bash
pytest tests/ -v -m "slow"
```

## Troubleshooting

### Common Issues:

**Import errors:**
```bash
# Solution: Add service directory to Python path
export PYTHONPATH="${PYTHONPATH}:$(pwd)"
```

**Mock not working:**
```python
# Ensure you're patching the right location
# Patch where it's imported, not where it's defined
with patch('main.function') as mock:  # ✅ Correct
    # not patch('other_module.function')  # ❌ Wrong
```

**Async test failures:**
```python
# Ensure you have @pytest.mark.asyncio
@pytest.mark.asyncio
async def test_async_function():
    result = await async_function()
```

## Contributing

When adding new features:
1. ✅ Write tests first (TDD)
2. ✅ Ensure tests pass
3. ✅ Maintain >80% coverage
4. ✅ Update this README if needed

## Resources

- [pytest documentation](https://docs.pytest.org/)
- [pytest-asyncio](https://pytest-asyncio.readthedocs.io/)
- [unittest.mock](https://docs.python.org/3/library/unittest.mock.html)
- [Coverage.py](https://coverage.readthedocs.io/)
