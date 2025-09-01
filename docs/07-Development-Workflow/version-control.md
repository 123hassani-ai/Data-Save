# کنترل نسخه Git - Version Control

## 📊 Document Information
- **Created:** 2025-09-01
- **Last Updated:** 2025-09-01
- **Version:** 1.0
- **Maintainer:** DataSave Development Team
- **Related Files:** `.gitignore`, `.github/`, `README.md`

## 🎯 Overview
راهنمای کامل استفاده از Git برای مدیریت نسخه‌های پروژه DataSave شامل branching strategy، commit conventions، و workflow های توسعه.

## 📋 Table of Contents
- [Git Repository Structure](#git-repository-structure)
- [Branching Strategy](#branching-strategy)
- [Commit Conventions](#commit-conventions)
- [Workflow Guidelines](#workflow-guidelines)
- [Release Management](#release-management)
- [Collaboration Guidelines](#collaboration-guidelines)
- [Git Hooks & Automation](#git-hooks--automation)
- [Troubleshooting](#troubleshooting)

## 📁 Git Repository Structure

### Repository Information
```yaml
Repository Name: Data-Save
Owner: 123hassani-ai
Platform: GitHub
URL: https://github.com/123hassani-ai/Data-Save
Primary Branch: main
License: MIT (or specified)
```

### Directory Structure
```
Data-Save/
├── .github/
│   ├── workflows/           # GitHub Actions CI/CD
│   ├── ISSUE_TEMPLATE/      # Issue templates
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── instructions/        # Repository instructions
├── .gitignore              # Git ignore rules
├── README.md              # Project documentation
├── CHANGELOG.md           # Version history
├── LICENSE               # Project license
├── backend/              # PHP Backend code
├── lib/                  # Flutter frontend code
├── docs/                 # Project documentation
├── test/                 # Test files
└── scripts/              # Build/deployment scripts
```

### .gitignore Configuration
```gitignore
# Flutter specific
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
flutter_*.png
linked_*.ds
unlinked.ds
unlinked_spec.ds

# IDEs
.vscode/
.idea/
*.swp
*.swo
*~

# OS specific
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Backend specific
backend/vendor/
backend/composer.lock
backend/.env
backend/config/database_local.php

# Logs
*.log
logs/
backend/api/logs/*.log

# Database
*.sql.backup
database_backup/
*.db
*.sqlite

# Security sensitive
api-keys.txt
.env.local
.env.production
config/secrets.php

# Build artifacts
dist/
*.tar.gz
*.zip

# Test coverage
coverage/
.nyc_output/
backend/reports/

# Node modules (if any)
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# PHP specific
*.phar
.phpunit.result.cache
phpunit.xml.dist
```

---

## 🌿 Branching Strategy

### Git Flow Model
```mermaid
gitgraph
    commit id: "Initial"
    
    branch develop
    checkout develop
    commit id: "Setup Dev"
    
    branch feature/dashboard
    checkout feature/dashboard
    commit id: "Dashboard UI"
    commit id: "Dashboard Logic"
    checkout develop
    merge feature/dashboard
    
    branch feature/settings
    checkout feature/settings
    commit id: "Settings API"
    commit id: "Settings UI"
    checkout develop
    merge feature/settings
    
    checkout main
    merge develop
    tag: "v1.0.0"
```

### Branch Types
```yaml
main:
  Purpose: Production-ready code
  Protection: Required PR reviews, CI checks
  Direct commits: Not allowed
  Deploy: Auto-deploy to production
  
develop:
  Purpose: Integration branch for features
  Source: main
  Target: main (via release branch)
  CI: Full test suite
  
feature/*:
  Purpose: New features development
  Naming: feature/dashboard, feature/form-builder
  Source: develop
  Target: develop
  Lifespan: Until feature complete
  
hotfix/*:
  Purpose: Critical production fixes
  Naming: hotfix/critical-bug-fix
  Source: main
  Target: main and develop
  Priority: Immediate attention
  
release/*:
  Purpose: Prepare production releases
  Naming: release/v1.2.0
  Source: develop
  Target: main
  Tasks: Version bump, final testing
```

### Branch Naming Conventions
```bash
# Features
feature/user-authentication
feature/form-builder-ui
feature/openai-integration
feature/persian-rtl-support

# Bug fixes
bugfix/settings-save-error
bugfix/dashboard-loading-issue
bugfix/rtl-layout-fix

# Hotfixes
hotfix/security-vulnerability
hotfix/database-connection-error
hotfix/critical-ui-bug

# Releases
release/v1.0.0
release/v1.1.0-beta
release/v2.0.0-rc1

# Chores
chore/update-dependencies
chore/improve-documentation
chore/refactor-api-service
```

---

## 📝 Commit Conventions

### Commit Message Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Commit Types
```yaml
feat: New feature implementation
fix: Bug fix
docs: Documentation updates
style: Code style changes (formatting, etc.)
refactor: Code refactoring
test: Adding or modifying tests
chore: Build process or auxiliary tool changes
perf: Performance improvements
ci: CI/CD configuration changes
build: Build system changes
```

### Commit Examples
```bash
# Feature commits
git commit -m "feat(dashboard): add statistics cards with Persian numbers

- Implement StatCard widget with RTL support
- Add Persian number formatting utility
- Include hover effects and navigation
- Update dashboard layout with responsive grid

Closes #23"

# Bug fix commits
git commit -m "fix(api): resolve CORS issues for Flutter web

- Add proper CORS headers in PHP backend
- Update API endpoints to handle preflight requests
- Test with local development server

Fixes #45"

# Documentation commits
git commit -m "docs(components): complete StatCard widget documentation

- Add usage examples and properties
- Include design specifications
- Document RTL support implementation
- Add golden test examples"

# Refactoring commits
git commit -m "refactor(services): improve API service error handling

- Centralize error handling logic
- Add retry mechanism for network requests
- Improve Persian error messages
- Update tests for new error flows"
```

### Persian Commit Messages (Optional)
```bash
# For Persian teams
git commit -m "feat(داشبورد): اضافه کردن کارت‌های آماری

- پیاده‌سازی StatCard با پشتیبانی RTL
- اضافه کردن فرمت اعداد فارسی
- شامل efekt hover و ناوبری"

# Mixed (Recommended for international collaboration)
git commit -m "feat(dashboard): اضافه کردن کارت‌های آماری

- Implement StatCard widget with RTL support
- Add Persian number formatting
- Include navigation to related pages"
```

---

## 🔄 Workflow Guidelines

### Daily Development Workflow
```bash
# 1. Start of day - Update local repository
git checkout develop
git pull origin develop

# 2. Create feature branch
git checkout -b feature/new-awesome-feature

# 3. Make changes and commit regularly
git add .
git commit -m "feat(feature): implement basic structure"

# Continue working...
git add .
git commit -m "feat(feature): add Persian translation support"

# 4. Push branch when ready for review
git push origin feature/new-awesome-feature

# 5. Create Pull Request via GitHub UI
# 6. Address review comments
git add .
git commit -m "fix(feature): address PR review comments"
git push origin feature/new-awesome-feature

# 7. After PR merge, cleanup
git checkout develop
git pull origin develop
git branch -d feature/new-awesome-feature
git push origin --delete feature/new-awesome-feature
```

### Pull Request Workflow
```yaml
PR Creation:
  Title: Clear, descriptive (same as main commit)
  Description: 
    - What changes were made
    - Why they were necessary  
    - How to test
    - Screenshots (if UI changes)
  Labels: feature, bug, documentation, etc.
  Assignee: Author or team lead
  Reviewers: At least 1 team member

PR Review Process:
  Code Review:
    - Check code quality and standards
    - Verify Persian/RTL support
    - Test functionality locally
    - Review documentation updates
  
  Approval Required:
    - At least 1 approved review
    - All CI checks passing
    - No merge conflicts
    - Documentation updated (if needed)

PR Merge:
  Strategy: Squash and merge (clean history)
  Title: Maintain semantic format
  Description: Summary of all changes
  Delete branch: After merge
```

### Release Workflow
```bash
# 1. Create release branch from develop
git checkout develop
git pull origin develop
git checkout -b release/v1.2.0

# 2. Update version numbers
# - pubspec.yaml (version)
# - package.json (if applicable)
# - Documentation versions
# - CHANGELOG.md

# 3. Final testing and bug fixes
git add .
git commit -m "chore(release): bump version to 1.2.0"

# 4. Create PR to main
git push origin release/v1.2.0
# Create PR: release/v1.2.0 → main

# 5. After PR approval and merge
git checkout main
git pull origin main
git tag v1.2.0
git push origin v1.2.0

# 6. Merge back to develop
git checkout develop
git merge main
git push origin develop

# 7. Clean up
git branch -d release/v1.2.0
git push origin --delete release/v1.2.0
```

---

## 🏷️ Release Management

### Semantic Versioning
```yaml
Version Format: MAJOR.MINOR.PATCH

MAJOR (1.0.0 → 2.0.0):
  - Breaking changes
  - Major architectural changes
  - API incompatibility
  
MINOR (1.0.0 → 1.1.0):
  - New features
  - Backward-compatible changes
  - New API endpoints
  
PATCH (1.0.0 → 1.0.1):
  - Bug fixes
  - Security patches
  - Documentation updates

Pre-release:
  - 1.2.0-alpha.1 (early testing)
  - 1.2.0-beta.2 (feature complete)  
  - 1.2.0-rc.1 (release candidate)
```

### Changelog Management
```markdown
# CHANGELOG.md

## [Unreleased]
### Added
- OpenAI integration for form generation
- Persian RTL support throughout the application

### Changed
- Updated Material Design 3 implementation
- Improved API error handling

### Fixed
- Dashboard loading performance issue
- CORS configuration for Flutter web

## [1.1.0] - 2025-09-01
### Added
- Settings management system
- System logging with Persian support
- Dashboard with statistics cards

### Changed
- Upgraded Flutter to 3.16.0
- Migrated to Material Design 3

### Fixed
- Database connection issues
- Persian text rendering problems

## [1.0.0] - 2025-08-15
### Added
- Initial release
- Basic PHP backend structure
- Flutter frontend foundation
- Database schema setup
```

### Git Tags
```bash
# Create annotated tags for releases
git tag -a v1.2.0 -m "Release version 1.2.0

New features:
- OpenAI integration
- Form builder UI
- Persian RTL support

Bug fixes:
- Dashboard performance
- API error handling"

# Push tags to remote
git push origin v1.2.0

# List all tags
git tag -l

# Show tag details
git show v1.2.0

# Delete tag (if needed)
git tag -d v1.2.0
git push origin --delete v1.2.0
```

---

## 👥 Collaboration Guidelines

### Code Review Checklist
```yaml
Functionality:
  ✅ Code works as intended
  ✅ Edge cases handled
  ✅ Error handling implemented
  ✅ Performance considerations

Code Quality:
  ✅ Follows project standards
  ✅ Clean and readable code
  ✅ Proper variable naming (Persian when needed)
  ✅ Comments for complex logic

Testing:
  ✅ Unit tests added/updated
  ✅ Integration tests pass
  ✅ Manual testing completed
  ✅ Performance impact assessed

Documentation:
  ✅ README updated (if needed)
  ✅ API documentation current
  ✅ Comments explain why, not what
  ✅ CHANGELOG.md updated

Persian/RTL:
  ✅ RTL layout properly implemented
  ✅ Persian text displays correctly
  ✅ Number formatting localized
  ✅ Date/time in Persian format
```

### Conflict Resolution
```bash
# When merge conflicts occur
git checkout feature/my-branch
git pull origin develop

# Resolve conflicts manually in IDE
# After resolving conflicts:
git add .
git commit -m "resolve: merge conflicts with develop"
git push origin feature/my-branch

# Alternative: Rebase (cleaner history)
git checkout feature/my-branch
git rebase develop

# Resolve conflicts during rebase
git add .
git rebase --continue
git push origin feature/my-branch --force-with-lease
```

### Communication Guidelines
```yaml
Commit Messages:
  Language: English (technical) + Persian (descriptions)
  Format: Consistent with conventions
  Detail: Explain why, not just what

PR Comments:
  Language: Persian for team communication
  English: For code-specific technical discussion
  Tone: Constructive and helpful
  Examples: Provide code suggestions

Issue Reporting:
  Title: Clear and descriptive
  Description: Steps to reproduce
  Labels: Appropriate categorization
  Assignment: To responsible team member
```

---

## 🔧 Git Hooks & Automation

### Pre-commit Hook
```bash
#!/bin/sh
# .git/hooks/pre-commit

echo "🔍 اجرای بررسی‌های pre-commit..."

# Check Flutter code format
echo "بررسی فرمت کد Flutter..."
flutter format --dry-run --set-exit-if-changed lib/
if [ $? -ne 0 ]; then
    echo "❌ کد Flutter نیاز به فرمت کردن دارد. لطفا 'flutter format lib/' اجرا کنید."
    exit 1
fi

# Run Flutter analyzer
echo "تحلیل کد Flutter..."
flutter analyze
if [ $? -ne 0 ]; then
    echo "❌ مشکلاتی در تحلیل کد Flutter وجود دارد."
    exit 1
fi

# Check PHP syntax
echo "بررسی syntax PHP..."
find backend -name "*.php" -exec php -l {} \; | grep -v "No syntax errors"
if [ $? -eq 0 ]; then
    echo "❌ خطای syntax در فایل‌های PHP وجود دارد."
    exit 1
fi

# Check commit message format
commit_msg=$(cat .git/COMMIT_EDITMSG)
if ! echo "$commit_msg" | grep -qE "^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .+"; then
    echo "❌ فرمت پیام commit صحیح نیست. لطفا از فرمت conventional commits استفاده کنید."
    echo "مثال: feat(dashboard): add Persian statistics cards"
    exit 1
fi

echo "✅ همه بررسی‌های pre-commit موفق بودند!"
exit 0
```

### Pre-push Hook
```bash
#!/bin/sh
# .git/hooks/pre-push

echo "🧪 اجرای تست‌ها قبل از push..."

# Run Flutter tests
echo "اجرای تست‌های Flutter..."
flutter test
if [ $? -ne 0 ]; then
    echo "❌ برخی تست‌های Flutter ناموفق بودند."
    exit 1
fi

# Run PHP tests (if phpunit is available)
if [ -f backend/vendor/bin/phpunit ]; then
    echo "اجرای تست‌های PHP..."
    cd backend
    ./vendor/bin/phpunit
    if [ $? -ne 0 ]; then
        echo "❌ برخی تست‌های PHP ناموفق بودند."
        exit 1
    fi
    cd ..
fi

echo "✅ همه تست‌ها موفق بودند. Push ادامه می‌یابد..."
exit 0
```

### GitHub Actions Integration
```yaml
# .github/workflows/pr-checks.yml
name: 🔍 PR Checks

on:
  pull_request:
    branches: [main, develop]

jobs:
  pr-validation:
    name: Validate PR
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Check PR title format
      run: |
        PR_TITLE="${{ github.event.pull_request.title }}"
        if ! echo "$PR_TITLE" | grep -qE "^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .+"; then
          echo "❌ PR title format is incorrect"
          echo "Expected format: type(scope): description"
          echo "Example: feat(dashboard): add Persian statistics cards"
          exit 1
        fi
        echo "✅ PR title format is correct"
    
    - name: Check for documentation updates
      run: |
        if git diff --name-only origin/main...HEAD | grep -qE "^(lib/|backend/)" && ! git diff --name-only origin/main...HEAD | grep -qE "^docs/"; then
          echo "⚠️ Warning: Code changes detected but no documentation updates found"
          echo "Please consider updating relevant documentation in docs/"
        fi
```

---

## 🔧 Troubleshooting

### Common Git Issues

#### Large Files Issue
```bash
# If you accidentally committed large files
git filter-branch --force --index-filter 
  'git rm --cached --ignore-unmatch path/to/large/file' 
  --prune-empty --tag-name-filter cat -- --all

# Push the cleaned history
git push origin --force --all
git push origin --force --tags
```

#### Reset to Previous State
```bash
# Reset to previous commit (keep changes)
git reset --soft HEAD~1

# Reset to previous commit (discard changes)
git reset --hard HEAD~1

# Reset to specific commit
git reset --hard commit_hash

# Undo last push (dangerous!)
git push origin --force-with-lease
```

#### Fix Commit History
```bash
# Amend last commit message
git commit --amend -m "new commit message"

# Interactive rebase to fix multiple commits
git rebase -i HEAD~3

# Squash commits
git reset --soft HEAD~3
git commit -m "feat(feature): combined commit message"
```

#### Branch Recovery
```bash
# Recover deleted branch
git reflog
git checkout -b recovered-branch commit_hash

# Recover from accidental reset
git reflog
git reset --hard commit_hash
```

### Performance Issues
```bash
# Clean up repository
git gc --aggressive --prune=now

# Reduce repository size
git repack -ad

# Clean untracked files
git clean -fd

# Remove old branches from remote tracking
git remote prune origin
```

---

## ⚠️ Important Notes

### Best Practices
- همیشه قبل از شروع کار branch جدید بسازید
- commit های کوچک و مرتبط انجام دهید
- پیام‌های commit را واضح و توصیفی بنویسید
- قبل از push حتما test ها را اجرا کنید
- از force push اجتناب کنید مگر در موارد ضروری

### Security Considerations
- هرگز اطلاعات حساس را commit نکنید
- از .gitignore برای فایل‌های محرمانه استفاده کنید
- API keys و passwords را در environment variables ذخیره کنید
- Regular audit برای exposed secrets انجام دهید

### Team Collaboration
- PR ها را به موقع review کنید
- نظرات سازنده و مفصل ارائه دهید
- از Persian برای communication داخلی استفاده کنید
- در conflict ها صبور باشید و مشورت کنید

---

## 🔄 Related Documentation
- [Development Environment](development-environment.md)
- [Code Standards](code-standards.md)
- [Testing Strategy](testing-strategy.md)
- [Build Deployment](build-deployment.md)
- [Project Structure](../01-Architecture/project-structure.md)

## 📚 References
- [Git Official Documentation](https://git-scm.com/doc)
- [GitHub Flow](https://guides.github.com/introduction/flow/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [Persian Git Guide](https://github.com/SajjadPourali/persian-git)

---
*Last updated: 2025-09-01*  
*File: docs/07-Development-Workflow/version-control.md*