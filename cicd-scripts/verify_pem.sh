#!/bin/bash
# Manual PEM verification script for Login.gov certificate
# Usage: ./verify_pem.sh [pem_file_path]

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $*"
}

PEM_FILE="${1:-/home/search/searchgov/shared/config/logindotgov.pem}"

echo "======================================================================"
echo "    Login.gov PEM Certificate Verification Tool"
echo "======================================================================"
echo ""

# Check if file exists
if [ ! -f "$PEM_FILE" ]; then
  log_error "PEM file not found: $PEM_FILE"
  exit 1
fi

log_info "Verifying PEM file: $PEM_FILE"
echo ""

# 1. Check file permissions
log_info "1. Checking file permissions..."
PERMS=$(stat -c "%a" "$PEM_FILE" 2>/dev/null || stat -f "%Lp" "$PEM_FILE" 2>/dev/null)
if [ "$PERMS" == "600" ] || [ "$PERMS" == "400" ]; then
  log_success "Permissions: $PERMS (secure)"
else
  log_warn "Permissions: $PERMS (should be 600 or 400)"
fi
echo ""

# 2. Check file size
log_info "2. Checking file size..."
FILE_SIZE=$(wc -c < "$PEM_FILE" | tr -d ' ')
if [ "$FILE_SIZE" -lt 100 ]; then
  log_error "File size: ${FILE_SIZE} bytes (too small, likely corrupt)"
  exit 1
elif [ "$FILE_SIZE" -gt 10000 ]; then
  log_warn "File size: ${FILE_SIZE} bytes (unusually large)"
else
  log_success "File size: ${FILE_SIZE} bytes"
fi
echo ""

# 3. Check for required PEM markers
log_info "3. Checking PEM format markers..."
HAS_BEGIN=$(grep -c "^-----BEGIN" "$PEM_FILE" || echo 0)
HAS_END=$(grep -c "^-----END" "$PEM_FILE" || echo 0)

if [ "$HAS_BEGIN" -eq 0 ]; then
  log_error "Missing BEGIN marker"
  log_info "First 5 lines of file:"
  head -5 "$PEM_FILE" | sed 's/^/    /'
  exit 1
fi

if [ "$HAS_END" -eq 0 ]; then
  log_error "Missing END marker"
  log_info "Last 5 lines of file:"
  tail -5 "$PEM_FILE" | sed 's/^/    /'
  exit 1
fi

log_success "Found BEGIN and END markers"
echo ""

# 4. Check for common corruption patterns
log_info "4. Checking for common corruption patterns..."
ISSUES=0

if grep -q $'\r' "$PEM_FILE"; then
  log_warn "Found Windows-style line endings (CRLF) - should be LF only"
  ISSUES=$((ISSUES + 1))
fi

if grep -q '\\n' "$PEM_FILE"; then
  log_warn "Found literal \\n escape sequences - should be actual newlines"
  ISSUES=$((ISSUES + 1))
fi

if grep -q '""' "$PEM_FILE"; then
  log_warn "Found double quotes in content"
  ISSUES=$((ISSUES + 1))
fi

if grep -qP '[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F-\x9F]' "$PEM_FILE"; then
  log_warn "Found non-printable control characters"
  ISSUES=$((ISSUES + 1))
fi

if [ "$ISSUES" -eq 0 ]; then
  log_success "No obvious corruption patterns detected"
else
  log_warn "Found $ISSUES potential corruption patterns"
fi
echo ""

# 5. Validate with OpenSSL (primary test)
log_info "5. Validating with OpenSSL pkey..."
if openssl pkey -in "$PEM_FILE" -noout 2>/dev/null; then
  log_success "OpenSSL pkey validation: PASSED"
else
  log_error "OpenSSL pkey validation: FAILED"
  log_info "OpenSSL error details:"
  openssl pkey -in "$PEM_FILE" -noout 2>&1 | sed 's/^/    /' || true
  exit 1
fi
echo ""

# 6. Try to parse as RSA key specifically
log_info "6. Validating as RSA private key..."
if openssl rsa -in "$PEM_FILE" -noout -check 2>/dev/null; then
  log_success "RSA key validation: PASSED"
else
  log_error "RSA key validation: FAILED"
  log_info "RSA validation error details:"
  openssl rsa -in "$PEM_FILE" -noout -check 2>&1 | sed 's/^/    /' || true
  exit 1
fi
echo ""

# 7. Extract and display key information
log_info "7. Key information:"
KEY_TYPE=$(openssl pkey -in "$PEM_FILE" -noout -text 2>/dev/null | head -1 || echo "Unknown")
echo "    Type: $KEY_TYPE"

KEY_SIZE=$(openssl rsa -in "$PEM_FILE" -noout -text 2>/dev/null | grep "Private-Key:" | sed 's/.*(\([0-9]*\).*/\1/' || echo "Unknown")
echo "    Size: ${KEY_SIZE} bits"

MODULUS_MD5=$(openssl rsa -in "$PEM_FILE" -noout -modulus 2>/dev/null | openssl md5 | awk '{print $2}')
echo "    Modulus MD5: $MODULUS_MD5"
echo ""

# 8. Test with Ruby OpenSSL (simulates Rails loading)
log_info "8. Testing with Ruby OpenSSL::PKey::RSA (Rails compatibility)..."
RUBY_TEST=$(ruby -e "
require 'openssl'
begin
  key = OpenSSL::PKey::RSA.new(File.read('$PEM_FILE'))
  puts 'SUCCESS'
  puts key.n.num_bits
rescue => e
  puts 'FAILED'
  puts e.class.to_s + ': ' + e.message
end
")

if echo "$RUBY_TEST" | grep -q "SUCCESS"; then
  KEY_BITS=$(echo "$RUBY_TEST" | tail -1)
  log_success "Ruby OpenSSL validation: PASSED (${KEY_BITS} bits)"
else
  log_error "Ruby OpenSSL validation: FAILED"
  log_info "Ruby error:"
  echo "$RUBY_TEST" | tail -1 | sed 's/^/    /'
  exit 1
fi
echo ""

# 9. Final summary
echo "======================================================================"
log_success "ALL VALIDATIONS PASSED"
echo "======================================================================"
echo ""
echo "The PEM file is valid and should work with Login.gov authentication."
echo ""
echo "Next steps:"
echo "  1. Ensure LOGIN_CLIENT_ID and LOGIN_IDP_BASE_URL are set"
echo "  2. Verify LOGIN_HOST matches your application domain"
echo "  3. Test Login.gov authentication flow"
echo ""

exit 0
