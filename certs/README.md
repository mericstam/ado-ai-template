# CA Certificates

Place your organization's root CA certificates here to enable HTTPS access to internal endpoints (e.g., Confluence, internal APIs).

## Usage

1. Add `.crt` files to this directory in your organization repo:
   ```
   certs/
   ├── internal-ca.crt
   ├── proxy-ca.crt
   └── another-ca.crt
   ```

2. The pipeline will automatically:
   - Mount the `certs/` directory into the container
   - Run `update-ca-certificates` to install them system-wide
   - All CLI tools (curl, wget, git, etc.) will trust these certificates

## Notes

- Files must have `.crt` extension
- PEM format is required (Base64 encoded, starts with `-----BEGIN CERTIFICATE-----`)
- Multiple certificates are supported
- This directory in the template repo should remain empty (org-specific certs only)
