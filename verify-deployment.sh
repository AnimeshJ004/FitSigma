#!/bin/bash

# FitSigma Deployment Verification Script
# Run this after deployment to verify changes are live

echo "============================================"
echo "FitSigma Deployment Verification"
echo "============================================"
echo ""

# Check if Railway CLI is installed
if command -v railway &> /dev/null; then
    echo "✓ Railway CLI detected"
    echo ""
    echo "Checking deployment status..."
    railway status
    echo ""
    echo "Recent logs (last 20 lines):"
    railway logs --lines 20
else
    echo "⚠ Railway CLI not installed"
    echo "Install with: npm i -g @railway/cli"
    echo ""
    echo "Or check deployment at: https://railway.app"
fi

echo ""
echo "============================================"
echo "Manual Verification Steps:"
echo "============================================"
echo "1. Visit your Railway deployment URL"
echo "2. Hard refresh: Ctrl+Shift+R (Windows/Linux) or Cmd+Shift+R (Mac)"
echo "3. Or open in incognito/private mode"
echo "4. Check if your changes are visible"
echo ""
echo "If changes still not visible:"
echo "- Check Railway dashboard for deployment status"
echo "- Verify environment variables are set correctly"
echo "- Try clearing Railway build cache in settings"
echo ""
echo "============================================"
