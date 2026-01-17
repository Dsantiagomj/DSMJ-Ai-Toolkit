# DevOps Special Cases & Incident Response

## Database Migrations in Production

### When
Schema changes need to be deployed to production

### Safety Steps
1. **Backup first**: Always backup before migration
2. **Test on staging**: Run migration on staging first
3. **Backward compatible**: Ensure app works before AND after migration
4. **Rollback plan**: Have rollback SQL ready
5. **Maintenance window**: Consider downtime if needed

### Example Process

```bash
# 1. Backup database
pg_dump $DATABASE_URL > backup-$(date +%Y%m%d).sql

# 2. Run migration
npx prisma migrate deploy

# 3. Verify schema changes
psql $DATABASE_URL -c "\d users" # Check schema

# Rollback if needed
psql $DATABASE_URL < backup-20260115.sql
```

### Best Practices
- Always create a backup before migrations
- Test migrations on staging environment first
- Use transactions where possible
- Have rollback scripts prepared
- Monitor application after migration
- Consider zero-downtime migrations for critical tables

## Secret Management

### When
Need to manage API keys, credentials, tokens

### Best Practices
✅ Use secret management service (AWS Secrets Manager, HashiCorp Vault)
✅ Environment variables for deployment
✅ Rotate secrets regularly
✅ Use .env.example without real values
❌ Never commit secrets to git
❌ Never hardcode in code
❌ Never log secrets

### GitHub Actions Secrets Example

```yaml
- name: Deploy
  env:
    DATABASE_URL: ${{ secrets.DATABASE_URL }}
    API_KEY: ${{ secrets.API_KEY }}
    STRIPE_SECRET: ${{ secrets.STRIPE_SECRET }}
  run: ./deploy.sh
```

### Secret Rotation Process
1. Generate new secret
2. Add new secret to secret manager
3. Update application to use new secret
4. Verify application works
5. Remove old secret after grace period

## Incident Response

### When
Production is down or degraded

### Steps

1. **Assess severity**
   - How many users affected?
   - What services are impacted?
   - Is data at risk?

2. **Communicate**
   - Update status page
   - Notify team in incident channel
   - Alert stakeholders if critical

3. **Investigate**
   - Check recent deployments
   - Review error logs
   - Check metrics and dashboards
   - Compare to baseline behavior

4. **Mitigate**
   - Rollback recent deploy if needed
   - Scale up resources if capacity issue
   - Failover to backup if available
   - Apply hotfix if quick fix available

5. **Resolve**
   - Fix root cause
   - Deploy fix to production
   - Verify resolution
   - Monitor for recurrence

6. **Post-mortem**
   - Document what happened
   - Identify root cause
   - Action items to prevent recurrence
   - Share learnings with team

### Runbook Template

```markdown
# Incident: [Title]

**Severity**: Critical/High/Medium/Low
**Start**: 2026-01-15 14:30 UTC
**End**: [Ongoing or timestamp]
**Duration**: [Time]

## Impact
- Users affected: [number or %]
- Services affected: [list]
- Data impact: [any data loss or corruption]

## Timeline
- 14:30 - Error rate spike detected in monitoring
- 14:32 - Investigated logs, found database connection errors
- 14:35 - Identified database CPU at 100%
- 14:37 - Scaled database from t3.medium to t3.large
- 14:40 - Error rate returned to normal
- 14:45 - Verified all services operational

## Root Cause
Database under-provisioned for Black Friday traffic spike.
Connection pool exhausted leading to timeout errors.

## Resolution
Scaled database from t3.medium to t3.large.
Increased connection pool size from 10 to 25.

## Prevention
- Set up auto-scaling for database
- Add alert for DB CPU >80%
- Add alert for connection pool >70% utilization
- Load test before major events
- Review capacity planning quarterly

## Action Items
- [ ] Implement database auto-scaling (Owner: DevOps, Due: 2026-01-20)
- [ ] Add CPU monitoring alerts (Owner: SRE, Due: 2026-01-17)
- [ ] Create load testing plan (Owner: QA, Due: 2026-01-25)
- [ ] Schedule capacity review (Owner: Architect, Due: 2026-02-01)
```

### Severity Levels

**Critical**
- Service completely down
- Data loss occurring
- Security breach active
- >50% users affected
- Response: Immediate, all hands on deck

**High**
- Major feature broken
- Performance severely degraded
- 10-50% users affected
- Response: Within 1 hour

**Medium**
- Minor feature broken
- Some users experiencing issues
- <10% users affected
- Response: Within 4 hours

**Low**
- Cosmetic issues
- Workaround available
- Minimal user impact
- Response: Next business day

## Rollback Procedures

### Vercel Rollback
```bash
# Via CLI
vercel rollback myapp --token=$VERCEL_TOKEN

# Via dashboard
# Deployments → Previous → Promote
```

### Docker Rollback
```bash
# If using blue-green
cp nginx.blue.conf /etc/nginx/sites-enabled/myapp.conf
nginx -s reload

# If using tags
docker-compose down
docker-compose -f docker-compose.previous.yml up -d
```

### Database Rollback
```bash
# Restore from backup
psql $DATABASE_URL < backup-20260115.sql

# Revert specific migration (Prisma)
npx prisma migrate resolve --rolled-back 20260115000000_migration_name
```

## Zero-Downtime Deployment Strategies

### For API Changes
1. Deploy backward-compatible version first
2. Migrate clients to new API
3. Remove old API in next release

### For Database Schema Changes
1. Add new column (nullable)
2. Deploy code that writes to both old and new columns
3. Backfill data
4. Deploy code that reads from new column
5. Remove old column

### For Breaking Changes
1. Version your API (/v1, /v2)
2. Run both versions in parallel
3. Migrate clients gradually
4. Deprecate old version after migration period
