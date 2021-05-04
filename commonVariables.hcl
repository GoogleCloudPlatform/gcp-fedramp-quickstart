schema = {
  title                = "Root module"
  description          = "This module is reusable so that it can be used both as an example and during integration tests."
  additionalProperties = false
  properties = {
        parent_type  = {
            description = "parent under which projects are residing/created. Parent type is one of the two 1) organization 2) folder"
            type        = "string"
        }
        parent_id  = {
            description = "The ID of the parent. Organization ID or Folder ID"
            type        = "string"
        }
        billing_account = {
            description = "Billing account ID. Example: 01F35C-D94AB9-***** "
            type        = "string"
        }
        owners_group    = {
            description = "Project owners group email ID for access control"
            type        = "string"
        }
        admin_group     = {
            description = "Org admin group email ID for access control"
            type        = "string"
        }
        cloud_users_group  = {
            description = "Cloud users group for access control. Cloud users group is used for post deployment access"
            type        = "string"
        }
#*********** Definitions of DevOps project variables *************************************
        terraform_state_storage_bucket  = {
            description = "Globally unique bucket name, which stores terraform state"
            type        = "string"
        }
        
#*********** Definitions of logging project variables *************************************
        logging_project_id = {
            description = "project ID of pre-created assuredworkload (project) for deploying log processing resources"
            type        = "string"
        }
        logging_project_region = {
            description = "The region used for the pre-created assured workload. Region can also be mentioned in data block."
            type        = "string"
        }

#************* Definitions of Three tier workload project variables *********************
        ttw_project_id = {
            description = "project ID of pre-created assuredworkload (project) for deploying three tier workload"
            type        = "string"
        }
        ttw_region = {
            description = "The region selected for the pre-created assured workload. Region can also be mentioned in data block. Example: us-central1"
            type        = "string"
        }
#************** Definitions of Three tier workload project Newtwork variables************ 
        vpc_network_name = {
            description = "Name of the VPC for the three tier workload project under which, GKE, Managed instance group etc will be created"
            type        = "string"
        }
        web_subnet_name = {
            description = "Name of the subnet (webserver subnet) under which Managed instance group to host webservers will be deployed"
            type        = "string"
        }
        web_subnet_ip_range = {
            description = "IP range for the webserber subnet to deploy webserver Managed instance group"
            type        = "string"
        }
        gke_subnet_name = {
            description = "Name of the subnet (GKE subnet) under which private GKE cluster (for application hosting) will be deployed"
            type        = "string"
        }
        gke_subnet_primary_ip_range = {
            description = "IP range for the GKE nodes "
            type        = "string"
        }
        gke_subnet_secondary_pod_ip_range = {
            description = "Secondary IP range for the pods in GKE"
            type        = "string"
        }
        gke_subnet_secondary_service_ip_range = {
            description = "Secondary IP range for the services in GKE"
            type        = "string"
        }
#************** Definitions of logging project Newtwork variables************************
        dataflow_network_name = {
            description = "Name of the VPC used by Dataflow workers"
            type        = "string"
        }
        dataflow_subnet_name = {
            description = "Name of the subnet used by Dataflow workers to launch VMs in"
            type        = "string"
        }
        dataflow_subnet_ip_range = {
            description = "IP CIDR range of dataflow subnet. dataflow worker VMs will use internal IP from this range"
            type        = "string"
        }
    }
}

template "variables" {
  recipe_path = "./variables.hcl"
  data = {

    # ******* Below variables values must be changed by user. Refer variable properties description in the above section before proceeding. *****************

    #parent_type example: "organization" or "folder"
    parent_type                             = ""
    #parent_id  example: "123456789***"
    parent_id                               = "" 
    #billing_account ID. Example: "01F35C-D94AB9-*****"
    billing_account                         = ""
    #owners_group example: "project-owners@example.com" 
    owners_group                            = ""
    #admin_group example:  "org-admins@example.com" 
    admin_group                             = ""
    #cloud_users_group example: "project-cloud-users@.example.com"
    cloud_users_group                       = ""
    #logging_project_id is the project ID of pre-created assured workload 'logging' project 
    logging_project_id                      = ""
    #logging_project_region is the region selected for logging project. Example: "us-central1"  
    logging_project_region                  = ""
    #ttw-project_id is the project ID of pre-created assured workload 'three tier workload' project 
    ttw_project_id                          = ""
    #ttw_region is region selected for three tier workload project. Example: "us-central1" 
    ttw_region                              = ""

    # ******* Below variable value must be changed by user and should be globally unique. *****************

    #Globally unique bucket name, which stores terraform state. 
    terraform_state_storage_bucket          = ""
  

    # ********** For below variables, default values can be retained. User can change these values based on requirement. *****************
    vpc_network_name                        = "ttw-fedramp-network"
    web_subnet_name                         = "ttw-fedramp-web-subnet"
    gke_subnet_name                         = "ttw-fedramp-gke-subnet"
    dataflow_network_name                   = "dataflow-worker-network"
    dataflow_subnet_name                    = "dataflow-worker-subnet"
    
    # ******** Below variable values must be changed as per your network design.  *****************
    web_subnet_ip_range                     = "10.0.1.0/24"
    gke_subnet_primary_ip_range             = "10.1.0.0/16"
    gke_subnet_secondary_pod_ip_range       = "10.2.0.0/16"
    gke_subnet_secondary_service_ip_range   = "10.3.0.0/24"
    dataflow_subnet_ip_range                = "10.200.10.0/24"
  }
}
