# Asset Deployment Migration: Capistrano to CodeDeploy

## Overview

This document describes the migration of asset deployment from Capistrano to the current CodeDeploy-based deployment pipeline.

## Problem

When the project moved from Capistrano-based deployment to CodeDeploy with custom scripts, a critical step was missed: **uploading precompiled assets to S3**. 

While assets were being precompiled locally on deployment servers, they were never uploaded to S3, causing them to be unavailable via the CDN (configured through `ASSET_HOST` environment variable).

## What Capistrano Was Doing

The Capistrano deployment included these key components for asset handling:

### 1. `capistrano/rails/assets` Plugin
```ruby
require 'capistrano/rails/assets'
```
This plugin automatically:
- Precompiled assets during deployment
- Uploaded compiled assets to S3 (when configured)
- Managed asset versioning and cleanup

### 2. `deploy/before_symlink.rb` Script
```ruby
execute 'Install JavaScript dependencies and pre-compile assets' do
  cwd release_path
  environment NODE_ENV: 'production'
  command "sudo su search -c 'yarn install --production && RAILS_ENV=#{rails_env} bundle exec rake assets:precompile'"
end

# Create non-fingerprinted copies for legacy compatibility
run <<COMPILE
  cd #{release_path}/public/assets && \
  for js in sayt_loader_libs sayt_loader stats; do cp ${js}-*.js ${js}.js && cp ${js}-*.js.gz ${js}.js.gz; done && \
  for css in sayt; do cp ${css}-*.css ${css}.css && cp ${css}-*.css.gz ${css}.css.gz; done && \
  for png in bootstrap/glyphicons-halflings bootstrap/glyphicons-halflings-white; do cp ${png}-*.png ${png}.png; done && \
  find . -type f -perm 600 | xargs --no-run-if-empty chmod 644
COMPILE
```

## Current CodeDeploy Implementation

### Deployment Flow

The deployment now follows this sequence (defined in `appspec.yml`):

1. **ApplicationStop** - Stop running services
2. **BeforeInstall** - Prepare environment, fetch environment variables
3. **AfterInstall** - Main deployment tasks:
   - `after_install.sh` - Install gems, JavaScript dependencies, precompile assets
   - `copy_non_fingerprinted_assets.sh` - Create legacy non-fingerprinted asset copies
   - **`upload_assets_to_s3.sh`** ← **NEW: Upload assets to S3**
4. **ApplicationStart** - Start services
5. **ValidateService** - Verify deployment success

### New Script: `upload_assets_to_s3.sh`

This script replicates the S3 upload functionality that Capistrano's `rails/assets` plugin provided:

**Key Features:**
- Uploads assets from `public/assets/` (Sprockets) and `public/packs/` (Webpacker)
- Sets appropriate cache headers:
  - Fingerprinted assets: `max-age=31536000, immutable` (1 year)
  - Non-fingerprinted assets: `max-age=3600` (1 hour)
- Makes assets publicly readable (`--acl public-read`)
- Cleans up old assets with `--delete` flag
- Handles both compressed (`.gz`) and uncompressed assets

**Script Logic:**
```bash
# Upload fingerprinted assets (with content hash in filename)
aws s3 sync "$source_dir" "s3://${S3_BUCKET}${s3_path}" \
  --include "*-*.js" --include "*-*.css" --include "*-*.png" \
  --cache-control "public, max-age=31536000, immutable" \
  --acl public-read --delete

# Upload non-fingerprinted assets (stable filenames for legacy support)
aws s3 sync "$source_dir" "s3://${S3_BUCKET}${s3_path}" \
  --exclude "*-*.*" \
  --cache-control "public, max-age=3600" \
  --acl public-read
```

## Required Environment Variables

The following environment variables must be configured in the deployment environment:

| Variable | Description | Example |
|----------|-------------|---------|
| `AWS_BUCKET` | S3 bucket name for asset storage | `search-gov-assets` |
| `AWS_ACCESS_KEY_ID` | AWS access key with S3 write permissions | `AKIA...` |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | `secret...` |
| `AWS_REGION` | AWS region for the S3 bucket | `us-east-1` |
| `ASSET_HOST` | CDN/CloudFront URL for serving assets | `https://assets.search.gov` |

These variables are fetched by `cicd-scripts/fetch_env_vars.sh` from AWS Systems Manager Parameter Store and stored in `/home/search/searchgov/shared/.env`. The upload script sources this file to access the configuration.

**Note:** The codebase uses `AWS_BUCKET` (as defined in `config/initializers/s3.rb`), not `AWS_S3_BUCKET`.

## Asset Types Handled

### Sprockets Assets (`public/assets/`)
- JavaScript files: `*.js`, `*.js.gz`
- CSS files: `*.css`, `*.css.gz`
- Images: `*.png`, `*.jpg`, `*.jpeg`, `*.gif`, `*.svg`
- Fonts: `*.woff`, `*.woff2`, `*.ttf`, `*.eot`

### Webpacker Assets (`public/packs/`)
- JavaScript bundles
- CSS bundles
- Source maps
- Manifest files

### Non-Fingerprinted Assets (Legacy Support)
Created by `copy_non_fingerprinted_assets.sh`:
- `sayt_loader_libs.js` (and `.js.gz`)
- `sayt_loader.js` (and `.js.gz`)
- `stats.js` (and `.js.gz`)
- `sayt.css` (and `.css.gz`)
- Various PNG icons

These files have stable names for external consumers that cannot be updated when asset fingerprints change.

## Testing the Deployment

### Pre-Deployment Checklist
1. ✅ Verify S3 bucket exists and is accessible
2. ✅ Confirm IAM permissions allow `s3:PutObject`, `s3:PutObjectAcl`, `s3:DeleteObject`, `s3:ListBucket`
3. ✅ Validate environment variables are set correctly
4. ✅ Test AWS CLI access: `aws s3 ls s3://your-bucket-name/`

### Post-Deployment Verification
1. **Check S3 bucket contents:**
   ```bash
   aws s3 ls s3://your-bucket-name/assets/ --recursive | head -20
   aws s3 ls s3://your-bucket-name/packs/ --recursive | head -20
   ```

2. **Verify asset accessibility:**
   ```bash
   curl -I https://your-asset-host/assets/application-[hash].css
   curl -I https://your-asset-host/packs/application-[hash].js
   ```

3. **Check cache headers:**
   ```bash
   curl -I https://your-asset-host/assets/application-[hash].css | grep -i cache-control
   # Should show: cache-control: public, max-age=31536000, immutable
   
   curl -I https://your-asset-host/assets/sayt_loader.js | grep -i cache-control
   # Should show: cache-control: public, max-age=3600
   ```

4. **Review deployment logs:**
   ```bash
   # On deployment server
   grep "UPLOAD_ASSETS" /var/log/aws/codedeploy-agent/codedeploy-agent.log
   ```

## Rollback Considerations

If the asset upload fails during deployment:

1. The deployment hook will fail and CodeDeploy will mark the deployment as failed
2. Assets from the previous deployment remain in S3 (due to `--delete` only removing files not in current upload)
3. The application will continue serving old assets until a successful deployment completes

To manually rollback assets:
```bash
# List previous asset versions (if versioning is enabled)
aws s3api list-object-versions --bucket your-bucket-name --prefix assets/

# Restore a specific version
aws s3api restore-object --bucket your-bucket-name --key assets/file.js --version-id VERSION_ID
```

## Comparison: Capistrano vs CodeDeploy

| Aspect | Capistrano | CodeDeploy |
|--------|------------|------------|
| Asset precompilation | ✅ `capistrano/rails/assets` | ✅ `after_install.sh` |
| S3 upload | ✅ `capistrano/rails/assets` | ✅ `upload_assets_to_s3.sh` |
| Non-fingerprinted copies | ✅ `deploy/before_symlink.rb` | ✅ `copy_non_fingerprinted_assets.sh` |
| Cache headers | ✅ Automatic | ✅ Explicit in script |
| Cleanup old assets | ✅ Automatic | ✅ `--delete` flag |
| Parallel uploads | ⚠️ Limited | ✅ AWS CLI optimization |
| Error handling | ⚠️ Mixed | ✅ Explicit with `set -euo pipefail` |

## Maintenance

### Regular Tasks
- Monitor S3 bucket size and costs
- Review CloudWatch metrics for CDN cache hit rates
- Audit asset upload logs for failures

### Future Improvements
- Consider implementing asset versioning in S3 for easier rollbacks
- Add CloudFront cache invalidation after asset uploads
- Implement parallel uploads for faster deployment
- Add pre-deployment asset diff to show what will change

## Related Files

- `appspec.yml` - Deployment hook configuration
- `cicd-scripts/after_install.sh` - Asset precompilation
- `cicd-scripts/copy_non_fingerprinted_assets.sh` - Legacy asset support
- `cicd-scripts/upload_assets_to_s3.sh` - S3 upload (new)
- `config/environments/production.rb` - `config.asset_host` configuration
- `config/initializers/s3.rb` - S3 credentials configuration
- `Capfile` - Old Capistrano configuration (reference)
- `deploy/before_symlink.rb` - Old Capistrano hook (reference)

## Support

For issues related to asset deployment:
1. Check CodeDeploy deployment logs
2. Verify S3 bucket permissions and configuration
3. Confirm environment variables are set correctly
4. Review CloudWatch logs for detailed error messages
