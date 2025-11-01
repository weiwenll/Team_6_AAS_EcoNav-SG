# Quick Start: Integrating Unit Tests

## 🚀 5-Minute Setup

### Step 1: Copy Files to Your Repository

Copy these files from the outputs directory to your repository:

```bash
# From your repository root
cp -r outputs/tests/ .
cp outputs/pytest.ini .
cp outputs/requirements-test.txt .
cp outputs/run-tests.sh .
cp -r outputs/.github/ .
```

### Step 2: Install Dependencies

```bash
pip install -r requirements-test.txt
```

### Step 3: Run Tests

```bash
chmod +x run-tests.sh
./run-tests.sh
```

**Expected Output:**
```
================================
  Running Unit Tests
================================

Installing test dependencies...
Running pytest...

tests/test_intent_classification.py ✓✓✓✓✓
tests/test_requirements_gathering.py ✓✓✓✓✓✓✓
tests/test_security.py ✓✓✓✓✓✓✓✓
tests/test_session_management.py ✓✓✓✓✓
tests/test_api_gateway.py ✓✓✓✓✓

================================
  ✅ All tests passed!
================================

Coverage report generated:
  - HTML: htmlcov/index.html
  - XML: coverage.xml
```

---

## 📁 File Structure

After integration, your repository will look like this:

```
your-repo/
├── .github/
│   └── workflows/
│       └── ci-cd.yml              ✨ NEW - CI/CD pipeline
├── tests/                         ✨ NEW - All test files
│   ├── conftest.py
│   ├── test_intent_classification.py
│   ├── test_requirements_gathering.py
│   ├── test_security.py
│   ├── test_session_management.py
│   ├── test_api_gateway.py
│   └── README.md
├── pytest.ini                     ✨ NEW - Pytest config
├── requirements-test.txt          ✨ NEW - Test dependencies
├── run-tests.sh                   ✨ NEW - Test runner
├── api-gateway/                   (existing)
├── intent-requirements-service/   (existing)
├── shared-services/               (existing)
└── ...
```

---

## ✅ Verification Checklist

Run through this checklist to ensure everything works:

- [ ] Files copied to repository root
- [ ] Dependencies installed (`pip install -r requirements-test.txt`)
- [ ] Tests execute successfully (`./run-tests.sh`)
- [ ] Coverage report generated (`htmlcov/index.html`)
- [ ] No import errors
- [ ] All tests passing (95+ tests)

---

## 🔧 Common Issues & Fixes

### Issue 1: Import Errors

**Error:**
```
ImportError: No module named 'main'
```

**Fix:**
```bash
export PYTHONPATH="${PYTHONPATH}:$(pwd)"
pytest tests/
```

Or add to `pytest.ini`:
```ini
[pytest]
pythonpath = .
```

### Issue 2: Missing Dependencies

**Error:**
```
ModuleNotFoundError: No module named 'pytest_asyncio'
```

**Fix:**
```bash
pip install -r requirements-test.txt
```

### Issue 3: Tests Fail Due to Environment Variables

**Error:**
```
KeyError: 'OPENAI_API_KEY'
```

**Fix:**
Tests automatically set mock environment variables. If you see this error, ensure you're running tests via:
```bash
./run-tests.sh
```

Or set manually:
```bash
export OPENAI_API_KEY="test-key-12345"
export USE_S3="false"
export GUARDRAILS_ENABLED="false"
pytest tests/
```

---

## 📊 Understanding Test Results

### Successful Run:
```
tests/test_intent_classification.py::TestIntentClassification::test_greeting_classification PASSED [1/95]
tests/test_intent_classification.py::TestIntentClassification::test_planning_classification PASSED [2/95]
...
==================== 95 passed in 12.34s ====================
```

### Failed Test:
```
tests/test_security.py::TestSecurityPipeline::test_validate_malicious_input FAILED [45/95]

================================ FAILURES ================================
________ TestSecurityPipeline.test_validate_malicious_input ________

    def test_validate_malicious_input(self):
>       assert result["is_safe"] is False
E       AssertionError: assert True is False

tests/test_security.py:45: AssertionError
```

**To debug:**
```bash
pytest tests/test_security.py::TestSecurityPipeline::test_validate_malicious_input -vv
```

---

## 🎯 Running Specific Tests

### Run Single File:
```bash
pytest tests/test_intent_classification.py -v
```

### Run Single Test:
```bash
pytest tests/test_security.py::TestSecurityPipeline::test_validate_malicious_input -v
```

### Run by Marker:
```bash
pytest tests/ -v -m "security"      # Only security tests
pytest tests/ -v -m "integration"   # Only integration tests
pytest tests/ -v -m "unit"          # Only unit tests
```

### Run with Coverage:
```bash
pytest tests/ --cov=. --cov-report=html
open htmlcov/index.html
```

---

## 🔄 CI/CD Setup

### GitHub Secrets Required

Add these secrets to your GitHub repository (Settings → Secrets → Actions):

```
AWS_ACCESS_KEY_ID              # Your AWS access key
AWS_SECRET_ACCESS_KEY          # Your AWS secret key
OPENAI_API_KEY_STAGING         # OpenAI key for staging
OPENAI_API_KEY_PROD            # OpenAI key for production
```

### Workflow Triggers

The CI/CD pipeline runs on:
- ✅ Every push to `main` branch
- ✅ Every push to `develop` branch
- ✅ Every pull request

### Pipeline Status

After pushing, check pipeline status at:
```
https://github.com/your-username/your-repo/actions
```

---

## 📈 Improving Coverage

### Current Coverage: ~82%

To reach 90%:

1. **Add tests for edge cases:**
   - Empty inputs
   - Very long inputs
   - Malformed data
   - Network timeouts

2. **Add tests for error paths:**
   - Exception handling
   - Retry logic
   - Fallback mechanisms

3. **Find untested code:**
   ```bash
   pytest tests/ --cov=. --cov-report=term-missing
   ```

4. **Focus on uncovered lines** shown in the report

---

## 🎓 Next Steps

### Week 1: Stabilization
- ✅ Run tests daily
- ✅ Fix any failures
- ✅ Review coverage reports
- ✅ Add tests for new features

### Week 2: Integration
- ✅ Set up CI/CD pipeline
- ✅ Add GitHub branch protection
- ✅ Require tests to pass before merge
- ✅ Add Codecov badge to README

### Week 3: Enhancement
- ✅ Add performance tests
- ✅ Add load tests
- ✅ Improve coverage to 90%+
- ✅ Add mutation testing

---

## 💡 Tips for Success

1. **Run tests before committing:**
   ```bash
   ./run-tests.sh && git commit
   ```

2. **Write tests for new features first (TDD)**

3. **Keep tests fast** (use mocks for external services)

4. **Review coverage regularly**:
   ```bash
   pytest tests/ --cov=. --cov-report=html
   ```

5. **Use test fixtures** to avoid duplication

6. **Document complex test scenarios**

---

## 📞 Need Help?

1. Check `tests/README.md` for detailed documentation
2. Review test examples in test files
3. Use verbose mode: `pytest tests/ -vv`
4. Use debugger: `pytest tests/ --pdb`

---

## ✅ You're Ready!

Your test suite is complete and ready to use. Just follow these steps:

1. Copy files to your repository
2. Install dependencies
3. Run tests
4. Commit to git
5. Push to trigger CI/CD

**Happy Testing! 🎉**
