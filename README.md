# terragrunt-logscale-multicloud

## Development

### AWS Auth

```bash
saml2aws login --force ; saml2aws exec $SHELL
```

### GCP Auth

```bash
gcloud auth login
gcloud auth application-default login
```

# Azure

az feature register --name EncryptionAtHost  --namespace Microsoft.Compute
