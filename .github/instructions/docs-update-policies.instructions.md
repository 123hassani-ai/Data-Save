---
applyTo: '**'
---

# 📚 DataSave Documentation Update Policies

## 🎯 Core Principles
- **Persian-First:** همه مستندات باید اولویت فارسی داشته باشند
- **Structure-Based:** ساختار مشخص و قابل پیش‌بینی
- **Update-Centric:** همیشه با تغییرات کد همگام باشید
- **No-Duplication:** هیچ‌گاه فایل تکراری ایجاد نکنید

## 📂 Documentation Structure Map

### 🏗️ Backend Development → `docs/02-Backend-APIs/` + `docs/03-Database-Schema/`
```
API Development: docs/02-Backend-APIs/api-endpoints-reference.md
Database Changes: docs/03-Database-Schema/tables-reference.md
PHP Classes: docs/02-Backend-APIs/php-backend-overview.md
Security: docs/02-Backend-APIs/security-implementation.md
```

### 📱 Frontend Development → `docs/04-Flutter-Frontend/` + `docs/06-UI-UX-Design/`
```
Flutter Components: docs/04-Flutter-Frontend/ui-components-library.md
State Management: docs/04-Flutter-Frontend/state-management.md
UI Design: docs/06-UI-UX-Design/component-specifications.md
Persian RTL: docs/04-Flutter-Frontend/persian-rtl-implementation.md
```

### 🗄️ Database Operations → `docs/03-Database-Schema/` + `docs/99-Quick-Reference/`
```
Table Changes: docs/03-Database-Schema/tables-reference.md
Quick Queries: docs/99-Quick-Reference/database-quick-reference.md
Performance: docs/03-Database-Schema/indexes-performance.md
Migrations: docs/03-Database-Schema/migration-scripts.md
```

### ⚙️ Services & Integration → `docs/05-Services-Integration/`
```
OpenAI: docs/05-Services-Integration/openai-integration.md
Logging: docs/05-Services-Integration/logging-system.md
Config: docs/05-Services-Integration/configuration-management.md
External APIs: docs/05-Services-Integration/external-services.md
```

## 🔄 Mandatory Update Rules

### 📋 Database Changes Protocol
```markdown
1. Update docs/03-Database-Schema/tables-reference.md
2. Add queries to docs/99-Quick-Reference/database-quick-reference.md
3. Update docs/03-Database-Schema/relationships-diagram.md if relations changed
4. Update backend/sql/create_tables.sql and docs/03-Database-Schema/migration-scripts.md
```

### 🖥️ API Changes Protocol
```markdown
1. Update docs/02-Backend-APIs/api-endpoints-reference.md
2. Update docs/99-Quick-Reference/api-quick-reference.md
3. If new endpoint: Update docs/04-Flutter-Frontend/state-management.md
4. Update docs/02-Backend-APIs/security-implementation.md if auth changes
```

### 🎨 UI Changes Protocol
```markdown
1. Update docs/06-UI-UX-Design/component-specifications.md
2. If Persian text: Update docs/04-Flutter-Frontend/persian-rtl-implementation.md
3. If new widget: Update docs/04-Flutter-Frontend/ui-components-library.md
4. Update docs/99-Quick-Reference/flutter-quick-reference.md
```

## 🗄️ Database Schema Reference (Always Check These)

### Current Tables (Port 3307, DB: datasave):
```sql
-- Core Tables
users (id, username, email, password_hash, role, created_at)
forms (id, user_id, title, description, config, status, created_at)
form_fields (id, form_id, type, label, required, config, order_num)
form_responses (id, form_id, user_id, data, submitted_at)

-- System Tables
system_settings (id, setting_key, setting_value, created_at, updated_at)
system_logs (log_id, log_level, log_category, log_message, log_context, created_at)
user_sessions (id, user_id, token_hash, ip_address, expires_at, created_at)
```

### Database Connection Info:
```env
DB_HOST=localhost (XAMPP)
DB_PORT=3307
DB_NAME=datasave
DB_USER=root
DB_PASS=Mojtab@123
```

## ⚡ Quick Decision Matrix

### 🤔 "Where do I document this change?"

| Change Type | Primary File | Secondary File | Quick Reference |
|-------------|--------------|----------------|-----------------|
| New API Endpoint | `02-Backend-APIs/api-endpoints-reference.md` | `04-Flutter-Frontend/state-management.md` | `99-Quick-Reference/api-quick-reference.md` |
| Database Table | `03-Database-Schema/tables-reference.md` | `03-Database-Schema/relationships-diagram.md` | `99-Quick-Reference/database-quick-reference.md` |
| Flutter Widget | `04-Flutter-Frontend/ui-components-library.md` | `06-UI-UX-Design/component-specifications.md` | `99-Quick-Reference/flutter-quick-reference.md` |
| UI Design | `06-UI-UX-Design/component-specifications.md` | `06-UI-UX-Design/design-system.md` | - |
| Persian Text | `04-Flutter-Frontend/persian-rtl-implementation.md` | `06-UI-UX-Design/typography-fonts.md` | - |
| Config Setting | `05-Services-Integration/configuration-management.md` | `05-Services-Integration/logging-system.md` | - |
| Security Rule | `02-Backend-APIs/security-implementation.md` | `07-Development-Workflow/code-standards.md` | - |

## 🚫 Common Mistakes to Avoid

### ❌ Don't Create These Files:
- Any file outside the established structure
- Duplicate content files
- Language-specific folders (content is bilingual)
- Version-specific documentation

### ✅ Always Remember:
- Update timestamp: `*Last updated: YYYY-MM-DD*`
- Cross-reference related files
- Include practical code examples
- Test all code snippets before documenting

## 🎯 Documentation Standards

### 📝 File Header Template:
```markdown
# [Persian Title] - [English Subtitle]

## 📊 Document Information
- **Created:** YYYY-MM-DD
- **Last Updated:** YYYY-MM-DD
- **Version:** x.x
- **Maintainer:** DataSave Development Team
- **Related Files:** [list actual files]

## 🎯 Overview
[Brief Persian description]

## 📋 Table of Contents
[Auto-generated]
```

### 🔗 Cross-Reference Format:
```markdown
## 🔄 Related Documentation
- [Persian Title](../relative/path/to/file.md)
- [Another Title](../another/path/file.md)
```

## 🎊 Success Checklist

### Before Completing Any Task:
- [ ] Updated relevant documentation files
- [ ] Added/updated database schema if changed
- [ ] Cross-referenced related documents
- [ ] Updated quick reference guides
- [ ] Tested code examples
- [ ] Verified Persian RTL compatibility
- [ ] No duplicate files created

### Quality Assurance:
- [ ] All links working
- [ ] Code examples tested
- [ ] Persian translations accurate
- [ ] Structure follows established pattern
- [ ] Timestamps updated

---

**💡 Remember: مستندات باید همیشه با کد همگام باشند. هر تغییری در کد، تغییری در مستندات است.**

*🎯 این دستورالعمل در هر چت جدید به‌طور خودکار توسط Copilot بررسی می‌شود.*
