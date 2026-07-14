# Railway Deployment Fix Guide

## Problem
Changes visible on localhost but not appearing on Railway deployment.

## Root Cause
Laravel caches compiled views, routes, config, and assets. Railway may not clear these caches properly between deployments.

## Solution Applied

### 1. Updated `start.sh`
- Added forced cache clearing before app starts
- Manually removes all cached files in `storage/framework/views`, `storage/framework/cache`, and `bootstrap/cache`
- Ensures fresh compilation on every deployment

### 2. Steps to Deploy Your Changes

#### Option A: Force Rebuild on Railway (Recommended)
```bash
# 1. Commit your changes
git add .
git commit -m "Force cache clear on deployment"

# 2. Push to trigger Railway deployment
git push origin main
```

#### Option B: Manual Railway Cache Clear
1. Go to Railway dashboard
2. Select your project
3. Go to "Settings" → "General"
4. Click "Clear Build Cache"
5. Then go to "Deployments" and click "Redeploy" on latest deployment

#### Option C: Add Environment Variable (Force Fresh Build)
1. In Railway dashboard, go to your service
2. Add a new environment variable:
   - Key: `FORCE_REBUILD`
   - Value: Current timestamp or random string (e.g., `2026-07-14-fix`)
3. This forces Railway to rebuild from scratch

### 3. Verify Deployment
After deployment completes:
1. Visit your Railway URL
2. Hard refresh browser (Ctrl+Shift+R or Cmd+Shift+R)
3. Check if changes are visible

### 4. If Changes Still Not Visible

#### Clear Browser Cache
- Press Ctrl+Shift+R (Windows/Linux) or Cmd+Shift+R (Mac)
- Or open in incognito/private window

#### Check Railway Logs
```bash
# View deployment logs to confirm cache clearing worked
railway logs
```

Look for these lines:
```
=== Clearing all caches ===
Cache cleared successfully
```

#### Force Complete Rebuild
If nothing works, trigger a complete rebuild:
1. Delete `vendor` folder locally (optional)
2. Make a small change to `Dockerfile` (add a comment)
3. Commit and push again

## Common Issues

### Issue: Old cached files persist
**Solution**: The updated `start.sh` now manually deletes cached files

### Issue: Browser caching
**Solution**: Hard refresh or use incognito mode

### Issue: Railway using old image
**Solution**: Clear Railway build cache in settings

### Issue: Environment variables not updated
**Solution**: Check `.env` settings in Railway dashboard

## Prevention

To avoid this in future:
1. Always test in production-like environment
2. Use Railway's preview environments for testing
3. Add cache busting to assets (Laravel Mix versioning)
4. Consider using Redis/Memcached instead of file cache in production

## Quick Commands Reference

```bash
# Local testing
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear

# Check what's cached
ls -la storage/framework/views/
ls -la bootstrap/cache/

# Force rebuild
git commit --allow-empty -m "Force rebuild"
git push origin main
```
