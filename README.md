# Google Cloud FedRAMP aligned "Three Tier Workload"

<img width="835" alt="FedRAMP Aligned Three-Tier Architecture on GCP" src="https://user-images.githubusercontent.com/56096409/118192016-5ab5ec80-b3fa-11eb-89e0-39e7803756bc.jpg">

The three-tier architecture can be used to deploy a web-based application on Google Cloud. The entire architecture is deployed as two projects using [Cloud Data Protection Toolkit](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite).  

## Documentation
* [Quickstart](https://github.com/GoogleCloudPlatform/gcp-fedramp-quickstart/blob/master/README.md#quickstart)
* [Prerequisites](https://github.com/GoogleCloudPlatform/gcp-fedramp-quickstart/blob/master/README.md#prerequisites)
  * [Access Control](https://github.com/GoogleCloudPlatform/gcp-fedramp-quickstart/blob/master/README.md#access-control)
* [Deployment Phases](https://github.com/GoogleCloudPlatform/gcp-fedramp-quickstart/blob/master/README.md#deployment-phases)
  * [Clone the repository](https://github.com/GoogleCloudPlatform/gcp-fedramp-quickstart/blob/master/README.md#clone-the-repository)
  * [Update the variables in HCL files](https://github.com/GoogleCloudPlatform/gcp-fedramp-quickstart/blob/master/README.md#update-the-variables-in-hcl-files)
  * [Generate terraform files](https://github.com/GoogleCloudPlatform/gcp-fedramp-quickstart/blob/master/README.md#generate-terraform-files)
  * [Architecure deployment using terraform](https://github.com/GoogleCloudPlatform/gcp-fedramp-quickstart/blob/master/README.md#architecture-deployment-using-terraform)
* [Architecture diagram](https://github.com/zealsomani/gcp-fedramp-quickstart/blob/main/Architecture/FedRAMP%20Aligned%20three-tier%20architecture%20on%20Google%20Cloud.jpg) 
* [Use case description and user considerations](https://github.com/GoogleCloudPlatform/gcp-fedramp-quickstart/blob/master/Architecture/Three-Tier%20Architecture%20Use%20Case%20Description.md) 
* [HCL files](https://github.com/zealsomani/gcp-fedramp-quickstart/blob/main/README.md#hcl-files)
* [Useful FedRAMP links](https://github.com/GoogleCloudPlatform/gcp-fedramp-quickstart/blob/master/README.md#useful-fedramp-linkss)

## Quickstart

1. Prerequisites
   - Access Control
2. Deployment Phases
   - Clone the repository
   - Update the variables in HashiCorp configuration language (HCL) files
   - Generate terraform files
   - Architecture deployment using terraform

## Prerequisites

Run the [Data Protection Toolkit](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite) locally on a computer or by using Google Cloud Shell. 

Before you run the toolkit locally, install the following tools:

* [Go (1.14+)](https://golang.org/doc/go1.14) - an open source programming language to build software.
* [Cloud SDK](https://cloud.google.com/sdk/install) - a set of tools for managing resources and applications hosted on Google Cloud.
* [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) - a distributed version control system.
* [Terraform (0.14.4+)](https://www.terraform.io/downloads.html) - a cloud provisioning tool.
* [Google Workspaces](https://workspace.google.com/) or [Cloud Identity](https://cloud.google.com/identity/docs/overview) - Privileges to modify users and groups in Google Workspaces or Cloud Identity.
* [Google Cloud Organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization) - A Google Cloud organization with [Billing Account](https://cloud.google.com/billing/docs)
* A domain purchased from a Domain registrar (example: Google Domains).

If Google Cloud Shell is used to run the toolkit, Go (1.16), Git, and Cloud SDK are preinstalled. However, newer version of Terraform must be installed in Google Cloud Shell before deploying the template using the below steps:

1. Go to [Terraform Downloads](https://www.terraform.io/downloads.html) and copy the link of 'Linux 64-bit' binary by right clicking on it.
2. Download the Linux 64-bit binary into Google Cloud Shell.
```
$ wget <link copied from Terraform Downloads>
```
3. Unzip the downloaded file.
```
$ unzip <downloaded file name>
```
4. Move the unzipped terraform binary to /usr/local/bin
```
$ sudo cp terraform /usr/local/bin
```


### Access Control
Before deploying a template, create three groups: 
* Owner: project-owners@{DOMAIN} - This group is granted the owner's role for the project, which allows members to do anything permitted by organization policies within the project. Additions to the owner’s group should be for a short term and controlled tightly.  Members of this group get owners access to the devops project to make changes to the CICD project or to make changes to the Terraform state. Make sure to include yourself as an owner of this group. Otherwise, you might lose access to the devops project after the ownership is transferred to this group.
* Admin: org-admins@{DOMAIN} - Members of this group get administrative access to the org or folder. This group can be used in break-glass situations to give humans access to the org or folder to make changes. Include yourself as a member of this group to deploy the code templates.
* Cloud-users: project-cloud-users@{DOMAIN} - Members of this group will get access to the resources deployed by the toolkit post deployment.

The user groups running the template (org-admins group) should have the following IAM roles. 
* roles/resourcemanager.organizationAdmin on the org for org deployment.
* roles/resourcemanager.folderAdmin on the folder for folder deployment (This role is required if workloads are deployed under a folder instead of organization).
* roles/resourcemanager.projectCreator on the org or folder.
* roles/billing.admin on the billing account.
* roles/owner on assured-workload projects for FedRAMP aligned workload deployment (This role is also assigned to the project-owners group).

## Deployment Phases

Data Protection Toolkit deploys resources on [Google Assured Workload](https://cloud.google.com/assured-workloads) projects, however, the toolkit does not create these projects for Assured Workloads. Hence, before deploying the toolkit, the user must create two FedRAMP moderate assured workloads (one for three tier workload and one for logging project) using console or gcloud. Refer to this [Create a new workload environment](https://cloud.google.com/assured-workloads/docs/how-to-create-workload) link.

**Note: Create Assured workloads in regions where N2D machine type is supported. Refer to [Regions and zones](https://cloud.google.com/compute/docs/regions-zones) to see which regions support N2D machine type.**


### Clone the repository

1. Clone the Data Protection Toolkit git repository to a folder (locally or on cloud shell).

```
$ git clone https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite
$ cd healthcare-data-protection-suite
```
2. Install tfengine.

```
$ go install ./cmd/tfengine
```

3. Clone the FedRAMP aligned three-tier workload HCL files in a folder before running the tfengine.

```
#clone modularised .hcl files from github to a folder in local machine or cloud shell
$ git clone https://github.com/GoogleCloudPlatform/gcp-fedramp-quickstart.git
```

4. After the HCL files are cloned, configure the variable values in commonVariables.hcl and variable.hcl files based on requirements. Refer the ‘Update the variables in HCL files’ section below for details.


### Update the variables in HCL files

This repository contains Hashicorp Configuration Language (HCL) files for deployment of FedRAMP aligned "Three Tier Workload" using [Data Protection Toolkit](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite). The toolkit contains a suite of tools that can be used to manage key areas of your Google Cloud organization.

#### HCL files
This repository contains seven HCL files:
* variables.hcl: This file contains variables that will be supplied to all other HCL files.
* commonVaraibles.hcl: This file is used to centralize common variables, which were used repetitively in variables.hcl.
* devops.hcl: This file deploys devops project and terraform state storage bucket.
* network.hcl: This file is used to deploy two networks across two assured workload projects.
* loadbalancer-mig.hcl: This file is used to deploy front end resources such as Load balancer, Managed Instance group and so on in the Three Tier Workload project.
* gke-sql.hcl: This file is used to deploy the GKE cluster and SQL instance in the Three Tier Workload project.
* logging.hcl: This file is used to deploy Logging project resources.

#### Execution
The toolkit (tfengine) execution starts with the commonVariables.hcl file. The commonVariables.hcl file calls the variable.hcl file, which inturn calls five HCL files: devops.hcl, network.hcl, logging.hcl, loadbalancer-mig.hcl, gke-sql.hcl.

(commonVariables.hcl →  variable.hcl file → devops.hcl, network.hcl, logging.hcl, loadbalancer-mig.hcl, gke-sql.hcl)
 
Note: Variable values used in both commonVariables and variable files are for reference only. Please configure the variable values based on requirements. 

#### Key Considerations
In order to edit and customize the deployment to align to your requirements, please consider the following.
**Note: All the variables stated in the below sections reside in [commonVariables.hcl](https://github.com/GoogleCloudPlatform/gcp-fedramp-quickstart/blob/main/Infrastructure/commonVariables.hcl) and [variables.hcl](https://github.com/GoogleCloudPlatform/gcp-fedramp-quickstart/blob/main/Infrastructure/variables.hcl), and must be updated in these two files only.** 

##### devops.hcl variables
The devops.hcl file will:
* Deploy a devops project.
* Create a terraform state storage bucket.
 
Ensure that values for devops project ID "devops_project_id" (in variables.hcl) and bucket name "terraform_state_storage_bucket"  (in commonVariables.hcl) are globally unique.

##### network.hcl variables
The network.hcl will: 
* Create two networks i.e., one for the Three Tier Workload project and the other for the Logging project. Define Subnets’ primary and secondary CIDR ranges as per requirement.
* Enable Google private service access. 
 
**Note:** Default values are just for reference.

##### logging.hcl variables
The logging.hcl file creates: 
* Dataflow job with private worker(s).
* BigQuery dataset and table.
* Pub/Sub Topic and Subscription.
* IAM bindings for access.

Please define [BigQuery table schema](https://cloud.google.com/bigquery/docs/schemas) (in the logging.hcl file) based on the log sink filter and Pub/Sub messages format. Update the following variables with appropriate values as described.
* logging_project_id (in commonVariables.hcl): Project ID of the assured workload created for Logging resources deployment.
* logging_project_region (in commonVariables.hcl): Region selected while creating assured workload.
* dataflow_temp_storage_bucket_name (in variables.hcl): A globally unique bucket name.

Additionally, customize the remaining variables based on the requirements.
 
**Note:** Assured workloads for “Logging” and “Three Tier Workload” must be created before running the toolkit. Refer to section 3.5 in the [Solution Guide.](https://docs.google.com/document/d/1oEm2UMU82wmGvS_OGi-7iYw_Nlzt75ePIcSQ1KjGOGc/edit)

##### loadbalancer-mig.hcl variables
The loadbalancer-mig.hcl file creates:
* Instance template.
* Managed Instance Group (MIG).
* HTTPS Load Balancer, SSL certificate.
* DNS Zone & records.
* Health Checks.
* Cloud Armor.
* Log Sink to Logging project.
* Cloud load balancing backend bucket.
* Firewall for health checks.
* IAM for access.

As mentioned below, update the following variables with appropriate values.
* ttw_project_id (in commonVariables.hcl):  Project ID of the assured workload created for “Three Tier Workload” resources deployment.
* ttw_region (in commonVariables.hcl): Region selected while creating assured workload.
* load_balancer_ssl_certificate_domain_name (in variables.hcl): Name of the domain that will be mapped to Load Balancer public IP. 
Example "assuredworkload.dev."
* load_balancer_url_map_host (in variables.hcl): Name of the domain mapped to Load Balancer, which will distribute traffic to backends. 
Example "assuredworkload.dev"
* loadbalancer_backend_bucket_name (in variables.hcl): A globally unique bucket name.
* cloud_armor_security_policy_allow_range (in variables.hcl): IP range allowed by cloud armor policy. By default denies all traffic.


Additionally, customize the remaining variables based on the requirements.

##### gke-sql.hcl variables
The gke-sql.hcl file creates: 
* Private GKE cluster.
* Private Cloud SQL.
* Log sink to Logging project.
* IAM for access.
 
As mentioned below, update the following variables with appropriate values.
* cloud_sql_backup_export_bucket_name (in variables.hcl): A globally unique bucket name.
* ttw_project_log_sink_filter (in variables.hcl): Log filter to filter the streaming logs to Pub/Sub. 
 
Additionally, customize the remaining variables based on the requirements.


### Generate terraform files

To generate terraform configuration files using tfengine run the following command. This will generate 6 folders/subfolders with terraform configuration files in --output_path location.

Generated folders:
* devops
* logging/network
* logging/workload
* threetierworkload/network
* threetierworkload/loadbalancer-mig
* threetierworkload/gke-sql

```
# -config path is the path to downloaded .hcl files

$ tfengine --config_path=/{path-to-variablefile}/commonVariables.hcl --output_path=/{output-path}

# {path-to-variablefile}: path to commonVariable.hcl file.
# {output-path}: Folder path, where terraform configuration files are generated by tfengine.
```

### Architecture deployment using terraform

After generating terraform configurations using tfengine, run the generated main.tf files in the following order.

* Open DevOps folder and run terraform configuration. This will deploy a project and a terraform state storage bucket in the project with the name of choosing.

```
$ cd /{output-path}/devops
$ terraform init
$ terraform apply
```

* After the project and state bucket are deployed, go to devops.hcl file section shown below, uncomment and set the enable_gcs_backend to true.

```
template "devops" {
  recipe_path = "recipes/devops.hcl"
  output_path = "./devops"
  data = {
    # TODO(user): Uncomment and re-run the engine after the generated devops module has been deployed.
    # Run `terraform init` in the devops module to backup its state to GCS.
    # enable_gcs_backend = true

    admins_group = {
      id = “{{.admin_group}}”
      exists = true
    }
```

* Run the tfengine command once again and force copy the state to terraform state storage bucket. Further terraform configuration deployments will use this bucket to store terraform state. 

```
$ tfengine --config_path=/{path}/commonVariables.hcl --output_path=/{path}
$ cd /{output-path}/devops
$ terraform init -force-copy
```

* After the states are transferred to the state bucket, deploy network resources in logging project (assured workload). 

```
$ cd /{output-path}/logging/network
$ terraform init
$ terraform apply
```
* After the logging network is deployed, run the below commands to deploy remaining resources in the logging project (Assured Workload) such as Dataflow, Pub/Sub, BigQuery.

```
$ cd /{output-path}/logging/workload
$ terraform init
$ terraform apply
```
* Deploy the network in threetierworkload/network folder to create network, private service access and enable APIs  in three tier workload project.

```
$ cd /{output-path}/threetierworkload/network
$ terraform init
$ terraform apply
```

* Deploy the resources in threetierworkload/loadbalancer-mig folder to create resources such as , MIG, Cloud Load Balancing, Cloud Armor, Google Managed SSL, Managed DNS and so on.

```
$ cd /{output-path}/threetierworkload/loadbalancer-mig
$ terraform init
$ terraform apply
```

* Deploy the additional resources in threetierworkload/gke-sql folder to create resources such GKE and SQL.

```
$ cd /{output-path}/threetierworkload/gke-sql
$ terraform init
$ terraform apply
```

## Useful FedRAMP links

* [Google Cloud Platform supports FedRAMP compliance](https://cloud.google.com/security/compliance/fedramp/), and provides specific details on the approach to security and data protection in the [Google security whitepaper](https://cloud.google.com/security/overview/whitepaper/) and in the [Google Infrastructure Security Design Overview.](https://cloud.google.com/security/infrastructure/design/)
* To learn more about Google Cloud's Shared Responsibility Model, refer to the [Google Infrastructure Security Design Overview.](https://cloud.google.com/security/infrastructure/design/)
* Refer to the [FedRAMP Shared Security Model](https://cloud.google.com/assured-workloads/docs/concept-fedramp-moderate) and [Google Cloud FedRAMP Implementation Guide.](https://cloud.google.com/security/compliance/fedramp-guide) for additional guidance on FedRAMP shared responsibilities for Google Cloud Platform.
* For details on Google Cloud services covered by FedRAMP, refer to the [FedRAMP Marketplace](https://cloud.google.com/security/compliance/fedramp) by Google.
