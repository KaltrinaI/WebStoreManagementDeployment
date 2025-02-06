<#
.SYNOPSIS
    Deploys the full Kubernetes stack for a specified environment.

.DESCRIPTION
    This script, when placed in the WebstoreManagementDeployment folder, deploys
    the Kubernetes YAML files for the specified environment (dev, staging, or production).
    It first applies the namespace YAML file and then recursively applies all other YAML files
    from the corresponding subfolder.

.PARAMETER Environment
    The target environment to deploy. Valid values are: dev, staging, production.

.EXAMPLE
    .\StartStack.ps1 -Environment dev
    Deploys the development stack.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("dev", "staging", "production")]
    [string]$Environment
)

# $PSScriptRoot points to the folder containing this script (i.e. WebstoreManagementDeployment)
$baseFolder = $PSScriptRoot

# The environment folder is a subfolder of the current folder
$deploymentFolder = Join-Path $baseFolder $Environment

if (-not (Test-Path $deploymentFolder)) {
    Write-Error "Deployment folder for environment '$Environment' was not found at: $deploymentFolder"
    exit 1
}

Write-Host "Deploying environment: $Environment" -ForegroundColor Cyan

# Apply the namespace YAML first
$namespaceFile = Join-Path $deploymentFolder "namespace-$Environment.yaml"
if (Test-Path $namespaceFile) {
    Write-Host "Applying namespace file: $namespaceFile" -ForegroundColor Green
    kubectl apply -f $namespaceFile
} else {
    Write-Warning "Namespace file not found: $namespaceFile. Continuing with the rest..."
}

# Pause briefly to allow the namespace to be created before other resources are applied
Start-Sleep -Seconds 3

# Apply all other YAML files in the chosen environment folder recursively
Write-Host "Applying all resources from: $deploymentFolder" -ForegroundColor Green
kubectl apply -R -f $deploymentFolder

Write-Host "Deployment for environment '$Environment' completed." -ForegroundColor Cyan
