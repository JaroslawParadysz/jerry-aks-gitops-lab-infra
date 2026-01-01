# Azure AKS GitOps Infrastructure

This repository contains Terraform scripts to provision Azure infrastructure including:
- Azure Resource Group
- Virtual Network (VNet) with subnet
- Azure Kubernetes Service (AKS) cluster

## � Prerequisites

### 1. Create Azure Storage Account for Terraform State

Before running Terraform, you need to manually create a storage account to store the Terraform state file:

```powershell
az login

# Set variables (customize these values)
$RESOURCE_GROUP_NAME = "rg-terraform-state"
$STORAGE_ACCOUNT_NAME = "tfstateaksgitops"  # Must be globally unique, 3-24 chars, lowercase/numbers only
$CONTAINER_NAME = "tfstate"
$LOCATION = "westeurope"

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create storage account
az storage account create `
  --resource-group $RESOURCE_GROUP_NAME `
  --name $STORAGE_ACCOUNT_NAME `
  --sku Standard_LRS `
  --encryption-services blob `
  --location $LOCATION

# Create blob container
az storage container create `
  --name $CONTAINER_NAME `
  --account-name $STORAGE_ACCOUNT_NAME
```

**Important**: After creating the storage account, you'll add these values as GitHub Secrets (see below) so they're not hardcoded in your repository.

## 🔐 GitHub Secrets Setup

Since this is a public repository, all sensitive information is stored as **GitHub Secrets**. Follow these steps to configure them:

### Step 1: Create an Azure Service Principal

```powershell
az login

# Create a service principal with Contributor role
az ad sp create-for-rbac --name "github-actions-aks-gitops" `
  --role contributor `
  --scopes /subscriptions/{subscription-id} `
  --sdk-auth
```

This command will output JSON credentials. **Copy the entire JSON output** - you'll need it in the next step.

### Step 2: Configure GitHub Secrets

Go to your GitHub repository:
1. Navigate to **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add the following secrets:

#### Required Secrets:

| Secret Name | Description | Example Value |
|------------|-------------|---------------|
| `AZURE_CREDENTIALS` | JSON output from the `az ad sp create-for-rbac` command | `{"clientId": "...", "clientSecret": "...", ...}` |
| `TF_BACKEND_RESOURCE_GROUP_NAME` | Resource group for Terraform state storage account | `rg-terraform-state` |
| `TF_BACKEND_STORAGE_ACCOUNT_NAME` | Storage account name for Terraform state | `tfstateaksgitops` |
| `TF_BACKEND_CONTAINER_NAME` | Blob container name for Terraform state | `tfstate` |
| `TF_BACKEND_KEY` | State file name | `aks-gitops.tfstate` |
| `TF_VAR_CUSTOMER_NAME` | Customer name for resource naming (lowercase, no spaces) | `contoso` |
| `TF_VAR_MODULE_NAME` | Module name for resource naming (lowercase, no spaces) | `gitops` |
| `TF_VAR_ENV_NAME` | Environment name (dev, staging, prod) | `dev` |
| `TF_VAR_LOCATION` | Azure region | `West Europe` |

**Resource Naming Convention**: Resources will be named as `{customer-name}-{resource-abbreviation}-{module-name}-{env-name}`
- Example Resource Group: `contoso-rg-gitops-dev`
- Example VNet: `contoso-vnet-gitops-dev`
- Example AKS: `contoso-aks-gitops-dev`

#### Optional Secrets (using defaults if not set):

| Secret Name | Description | Default Value |
|------------|-------------|---------------|
| `TF_VAR_AKS_NODE_COUNT` | Number of AKS nodes | `2` |
| `TF_VAR_AKS_NODE_VM_SIZE` | VM size for AKS nodes | `Standard_D2s_v3` |

### Step 3: Example - Adding a Secret

```powershell
# Example: Adding AZURE_CREDENTIALS
# 1. Go to: https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions
# 2. Click "New repository secret"
# 3. Name: AZURE_CREDENTIALS
# 4. Value: Paste the JSON output from Step 1
# 5. Click "Add secret"
```

## 🚀 Usage

### Automatic Deployment (GitHub Actions)

The GitHub Actions workflow will automatically:
- **On Pull Request**: Run `terraform plan` to preview changes
- **On Push to main**: Run `terraform apply` to deploy infrastructure

**Note**: The workflow authenticates to Azure Storage backend using the Service Principal credentials from `AZURE_CREDENTIALS` secret.

### Manual Deployment (Local Development)

1. **Prerequisites**:
   - [Terraform](https://www.terraform.io/downloads) >= 1.0
   - [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
   - Azure subscription
   - Azure Storage Account created (see Prerequisites section above)

2. **Login to Azure**:
   ```powershell
   az login
   ```

3. **Navigate to the src directory**:
   ```powershell
   cd src
   ```

4. **Create a `terraform.tfvars` file** (copy from example):
   ```powershell
   Copy-Item terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

5. **Initialize Terraform with backend configuration**:
   ```powershell
   terraform init `
     -backend-config="resource_group_name=rg-terraform-state" `
     -backend-config="storage_account_name=tfstateaksgitops" `
     -backend-config="container_name=tfstate" `
     -backend-config="key=aks-gitops.tfstate"
   ```
   
   This will initialize the backend and download required providers. Terraform will authenticate to Azure Storage using your Azure CLI credentials.

6. **Plan the deployment**:
   ```powershell
   terraform plan
   ```

7. **Apply the configuration**:
   ```powershell
   terraform apply
   ```

## 📂 Project Structure

```
.
├── .github/
│   └── workflows/
│       └── terraform.yml          # GitHub Actions workflow
├── src/
│   ├── main.tf                    # Main infrastructure resources
│   ├── variables.tf               # Variable definitions
│   ├── outputs.tf                 # Output values
│   ├── providers.tf               # Provider configuration
│   ├── terraform.tfvars.example   # Example variables file
│   └── .gitignore                 # Ignore sensitive files
└── README.md
```

## 🔒 Security Best Practices

✅ **What's Protected**:
- Azure credentials stored in GitHub Secrets (encrypted)
- Service Principal credentials not visible in public repo
- `.tfvars` files are gitignored (never committed)
- Terraform state stored securely in Azure Storage Account
- State files are NOT committed to Git (protected by `.gitignore`)

✅ **What's Public** (and that's OK):
- Storage account name for Terraform state backend
- Backend configuration in `providers.tf`
- Resource names and infrastructure code

⚠️ **Important Notes**:
- Never commit `terraform.tfvars` or any files containing secrets
- Never hardcode credentials in `.tf` files
- Review the `.gitignore` file to ensure sensitive files are excluded
- Rotate your Service Principal credentials periodically
- The storage account is accessed via Azure authentication (CLI or Service Principal), not access keys in code

## 🗑️ Cleanup

To destroy the infrastructure:

```powershell
cd src
terraform destroy
```

Or manually delete the resource group in Azure Portal:
```powershell
az group delete --name rg-aks-gitops-dev --yes
```

## 📝 Notes

- The AKS cluster uses a System-Assigned Managed Identity
- Network plugin: Azure CNI
- Network policy: Calico
- Modify the variables in GitHub Secrets to customize your deployment

## ⏰ Cost Optimization - Automated Start/Stop

The infrastructure includes Azure Automation to automatically stop your AKS cluster:

**Schedules:**
- 🛑 **Stop**: Daily at 10 PM (W. Europe Time)
- ▶️ **Start**: Manual (you control when to start)

**Cost Savings**: ~70% reduction during stopped hours (still pay for disks and IPs)

**Manual Start/Stop:**
```powershell
# Start cluster manually
az aks start --name <cluster-name> --resource-group <rg-name>

# Stop cluster manually (if needed before 10 PM)
az aks stop --name <cluster-name> --resource-group <rg-name>

# Check cluster status
az aks show --name <cluster-name> --resource-group <rg-name> --query powerState
```

**Trigger Start Runbook from Azure Portal:**
1. Go to Automation Account → Runbooks
2. Select "Start-AKSCluster"
3. Click "Start"
4. Provide parameters (ResourceGroupName, ClusterName)

**Customize Stop Schedule:**
- Edit schedule in [src/automation.tf](src/automation.tf)
- Modify timezone or time
- Run `terraform apply` to update

## 🔗 Useful Commands

```powershell
# Get AKS credentials
az aks get-credentials --resource-group <rg-name> --name <aks-name>

# View cluster info
kubectl cluster-info

# Check nodes
kubectl get nodes
```

## 📚 Additional Resources

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Encrypted Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
