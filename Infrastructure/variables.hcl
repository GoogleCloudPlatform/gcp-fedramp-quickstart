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
            description = "Unique global bucket name, which stores terraform state"
            type        = "string"
        }
        owners_group    = {
            description = "Owners group for access control"
            type        = "string"
        }
        admin_group     = {
            description = "Admin group for access control"
            type        = "string"
        }
        cloud_users_group  = {
            description = "Cloud users group for access control. Cloud users group is used for post deployment access"
            type        = "string"
        }
#*********** Definitions of DevOps project variables *************************************
        devops_project_id = {
            description = "Unique project ID for the devops project. This project is created by this template. "
            type        = "string"
        }
        terraform_state_storage_bucket  = {
            description = "Unique global bucket name, which stores terraform state"
            type        = "string"
        }
        devops_storage_region = {
            description = "Region in which terraform state bucket stores state files. Example: us-central1"
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

#*********** Definitions of Logging project bigquery variables *****************************
        logs_storage_bigquery_dataset_name = {
            description = "logs analyis bigquery dataset name"
            type        = "string"
        }
        logs_storage_bigquery_table_name = {
            description = "logs analysis bigquey table name"
            type        = "string"
        }
#*********** Definitions of Logging project dataflow variables *****************************
        data_flow_job_name = {
            description = "the dataflow job name (used for logs processing)"
            type        = "string"
        }
        data_flow_job_max_workers = {
            description = "the number of dataflow job workers to be created"
            type        = "number"
        }
#*********** Definitions of Logging project pubsub variables *****************************
        logs_streaming_pubsub_topic_name = {
            description = "the pubsub topic name to receive logs from three tier workload project"
            type        = "string"
        }
        logs_streaming_pubsub_topic_datatype_label = {
            description = "the pubsub topic label values used in all the resources of this project"
            type        = "string"
        }
        logs_streaming_pubsub_topic_data_criticality_label = {
            description = "the pubsub topic label values used in all the resources of this project"
            type        = "string"
        }
        logs_streaming_pubsub_subscription_name = {
            description = "the pubsub subscription name created for the above topic"
            type        = "string"
        }
        logs_streaming_pubsub_subscription_acknowledgmenet_seconds = {
            description = "the pubsub subscription acknowledgement deadline seconds"
            type        = "number"
        }
#*********** Definitions of Logging project bucket variables *****************************
        dataflow_temp_storage_bucket_name = {
            description = "Temp storage bucket name used by dataflow job"
            type        = "string"
        }
        dataflow_temp_storage_bucket_datatype_label = {
            description = "the label values used by the temp files storage bucket"
            type        = "string"
        }
        dataflow_temp_storage_bucket_data_criticality_label = {
            description = "the label values used by the temp files storage bucket"
            type        = "string"
        }   
#************* Definitions of Three tier workload project variables *********************
        ttw_project_id = {
            description = "project ID of pre-created assuredworkload (project) for deploying three tier workload"
            type        = "string"
        }
        ttw_region = {
            description = "The region used for the pre-created assured workload. Region can also be mentioned in data block"
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
# ****************** Definitions of Three tier workload project Manged Instance group(MIG) variables ********
        ttw_instance_template_name = {
            description = "Name of the Instance template, which will be used for instances in MIG"
            type        = "string"
        }
        mig_name = {
            description = "Managed Instance Group(MIG) name"
            type        = "string"
        }
        mig_instance_type = {
            description = "the machine type of the instances in MIG. Use N2D machine type to support confidential compute."
            type        = "string"
        }
        mig_distribution_policy_zones = {
            description = "Zones in which the instances of MIG will be places. Zones should support N2D machine type"
            type = "object"
        }
        autoscaling_min_replicas = {
            description = "Minimum number of instances to be maintained by MIG"
            type        = "number"
        }
        autoscaling_max_replicas = {
            description = "Maximum number of instances to be scaled by MIG"
            type        = "number"
        }
        autoscaling_cooldown_period = {
            description = "The number of seconds that the autoscaler should wait before it starts collecting information from a new instances"
            type        = "number"
        }
        autoscaling_cpu_utilization = {
            description = "Value of CPU utilization metric to be used for scaling. value will be between 0 and 1 (example value 0.6 to scale up when CPU 60 percent utilized)"
            type        = "number"
        }
        mig_instance_datatype_label = {
            description = "the data type and data criticality label values. These labels will be used accross resources in three tier workload"
            type        = "string"
        } 
        mig_instance_data_criticality_label = {
            description = "the data type and data criticality label values. These labels will be used accross resources in three tier workload"
            type        = "string"
        } 
# ****************** Definitions of Three tier workload project HTTPS Load Balancer variables ***********************
        load_balancer_ssl_certificate_domain_name = {
            description = "The domain name to which google managed DV(domain verification) SSl certificate to be created."
            type        = "string"
        }  
        backend_mig_protocol = {
            description = "Load balancer Backend service(with MIG) listening protocol."
            type        = "string"
        } 
        backend_mig_timeout = {
            description = "Seconds to wait for the backend before considering it a failed request. Default is 30 seconds"
            type        = "number"
        }
        load_balancer_url_map_host = {
            description = "load balancer URL map host domain."
            type        = "string"
        }
        load_balancer_url_map_compute_backend_path = {
            description = "load balancer URL map backend path to MIG"
            type        = "string"
        } 
        load_balancer_url_map_bucket_backend_path = {
            description = "Load balancer URL map backend path to static files bucket"
            type        = "string"
        }
#******************* Definitions of Three tier workload project loadbalancer backend static bucket Variables ***********
        loadbalancer_backend_bucket_name = {
            description = "Unique name of the static files storage bucket. This is backend to https load balancer. Example: ttw-backend-bucket"
            type        = "string"
        }
#******************* Definitions of Three tier workload project HTTP health check *********************
        ttw_compute_http_health_check_name = {
            description = "The health check name (used for both instance group and HTTPS loadbalancer)"
            type        = "string"
        } 
        ttw_compute_http_health_check_timeout_sec = {
            description = "Timeout seconds to wait before claiming failure by health check"
            type        = "number"
        }
        ttw_compute_http_health_check_interval_sec = {
            description = "Interval seconds to send a health check"
            type        = "number"
        }
        ttw_compute_http_health_check_healthy_threshold = {
            description = "Healthy threshold with in which instance will be marked healthy after certain consecutive successes checks"
            type        = "number"
        }
        ttw_compute_http_health_check_unhealthy_threshold = {
            description = "UnHealthy threshold with in which instance will be marked unhealthy after certain consecutive failed checks"
            type        = "number"
        } 
        ttw_compute_http_health_check_request_path = {
            description = "Request path to probe the health check"
            type        = "string"
        } 
        ttw_compute_http_health_check_response = {
            description = "The reponse to the request "
            type        = "string"
        }
        ttw_compute_http_health_check_proxy_header = {
            description = "The type of proxy header to append before sending data to the backend"
            type        = "string"
        } 
#******************* Definitions of Three tier workload project Cloud Armor Variables *************************
        cloud_armor_security_policy_name = {
            description = "Cloud Armor Security policy name"
            type        = "string"
        }
        cloud_armor_security_policy_allow_range = {
            description = " Cloud Armor allow rule whitlisting IP range"
            type        = "string"
        } 
#******************* Definitions of Three tier workload project GKE variables *************************
        gke_private_cluster_name = {
            description = "Private GKE cluster name"
            type        = "string"
        }
        gke_private_master_ip_range = {
            description = "master authorized network IP ranges to access private GKE cluster master"
            type        = "string"
        }
        gke_node_pool_name = {
            description = "custom node pool name"
            type        = "string"
        }

        gke_node_pool_machine_type = {
            description = "machine type of the node pool instances"
            type        = "string"
        }

        gke_node_pool_min_instance_count = {
            description = "minimum instance count(perzone) in the node pool"
            type        = "number"
        }

        gke_node_pool_max_instance_count = {
            description = "maximum instance count (perzone) in the node pool when scaled."
            type        = "number"
        }

        gke_node_pool_instance_disk_size = {
            description = "disk size of the instances created in node pool"
            type        = "number"
        }

        gke_node_pool_image_type = {
            description = "Image type of the node pool instances"
            type        = "string"
        }
#******************* Definitions of Three tier workload project Cloud SQL Variables ***************************
        private_cloud_sql_name = {
            description = "Private Cloud SQL instance name"
            type        = "string"
        }
        private_cloud_sql_machine_type = {
            description = "machine type of the Cloud SQL instance"
            type        = "string"
        }
        cloud_sql_backup_export_bucket_name = {
            description = "Globally Unique bucket name. This bucket is used to store Cloud SQL backup exports"
            type        = "string"
        }
#******************* Definitions of Three tier workload project Logsink to logging project Variable ***********
        ttw_project_log_sink_filter = {
            description = "the filter string to send only certain logs to logging project"
            type        = "string"
        }
    }
}

# Note: Varible values, which are in the format {{.}} will be auto filled from commonVariables.hcl file. Only configure remaining variables.
template "devops" {
  recipe_path = "./devops.hcl"
  data = {
    # ******* Do not change below variables. These values are supplied by commonVariables.hcl ***********
    parent_type                             = "{{.parent_type}}"
    parent_id                               = "{{.parent_id}}" 
    billing_account                         = "{{.billing_account}}"
    owners_group                            = "{{.owners_group}}"
    admin_group                             = "{{.admin_group}}"
    cloud_users_group                       = "{{.cloud_users_group}}"
    terraform_state_storage_bucket          = "{{.terraform_state_storage_bucket}}"

    # ******* Below variables values must be changed by user *****************
    
    # Unique project ID for the devops project. This project is created by this template and is not a pre-existing project. 
    #devops_project_id example: "example-devops-project"
    devops_project_id                       = ""
    #devops_storage_region example: "us-central1"
    devops_storage_region                   = ""

  }
}

template "network" {
  recipe_path = "./network.hcl"
  data = {
    # ******* Do not change below variables. These values are supplied by commonVariables.hcl ***********
    parent_type                             = "{{.parent_type}}"   
    parent_id                               = "{{.parent_id}}" 
    billing_account                         = "{{.billing_account}}"
    terraform_state_storage_bucket          = "{{.terraform_state_storage_bucket}}"
    owners_group                            = "{{.owners_group}}"
    admin_group                             = "{{.admin_group}}"
    cloud_users_group                       = "{{.cloud_users_group}}"
    ttw_project_id                          = "{{.ttw_project_id}}"
    ttw_region                              = "{{.ttw_region}}"
    vpc_network_name                        = "{{.vpc_network_name}}"
    web_subnet_name                         = "{{.web_subnet_name}}"
    web_subnet_ip_range                     = "{{.web_subnet_ip_range}}" 
    gke_subnet_name                         = "{{.gke_subnet_name}}"
    gke_subnet_primary_ip_range             = "{{.gke_subnet_primary_ip_range}}"
    gke_subnet_secondary_pod_ip_range       = "{{.gke_subnet_secondary_pod_ip_range}}"
    gke_subnet_secondary_service_ip_range   = "{{.gke_subnet_secondary_service_ip_range}}"
    dataflow_network_name                   = "{{.dataflow_network_name}}"
    dataflow_subnet_name                    = "{{.dataflow_subnet_name}}"
    dataflow_subnet_ip_range                = "{{.dataflow_subnet_ip_range}}"
  }
}


template "logging" {
  recipe_path = "./logging.hcl"
  data = { 
    # ******* Do not change below variables. These values are supplied by commonVariables.hcl ***********
    parent_type                                                 = "{{.parent_type}}"   
    parent_id                                                   = "{{.parent_id}}" 
    billing_account                                             = "{{.billing_account}}"
    terraform_state_storage_bucket                              = "{{.terraform_state_storage_bucket}}"
    owners_group                                                = "{{.owners_group}}"
    admin_group                                                 = "{{.admin_group}}"
    cloud_users_group                                           = "{{.cloud_users_group}}"
    logging_project_id                                          = "{{.logging_project_id}}"
    logging_project_region                                      = "{{.logging_project_region}}"
    dataflow_network_name                                       = "{{.dataflow_network_name}}"
    dataflow_subnet_name                                        = "{{.dataflow_subnet_name}}"
    dataflow_subnet_ip_range                                    = "{{.dataflow_subnet_ip_range}}"
    
    # ********** For below variables, default values can be retained. User can change these values based on requirement ***********
    logs_storage_bigquery_dataset_name                          = "logs_storage_dataset" 
    logs_storage_bigquery_table_name                            = "central-logs-table1"
    data_flow_job_name                                          = "logs-streaming1"
    data_flow_job_max_workers                                   = 2
    logs_streaming_pubsub_topic_name                            = "logging-pubsub-topic"
    logs_streaming_pubsub_topic_datatype_label                  = "logs"
    logs_streaming_pubsub_topic_data_criticality_label          = "high"
    logs_streaming_pubsub_subscription_name                     = "logging-pubsub-subscription"
    logs_streaming_pubsub_subscription_acknowledgmenet_seconds  = 20
    dataflow_temp_storage_bucket_datatype_label                 = "temp-data"
    dataflow_temp_storage_bucket_data_criticality_label         = "low"

    # ******* Below variable value must be changed and should be globally unique ***********

    #Globally unique bucket name, used as staging bucket for dataflow job. Example: "example-dataflow-bucket"
    dataflow_temp_storage_bucket_name                           = ""
    
    
  }
}

template "frontend" {
  recipe_path = "./loadbalancer-mig.hcl"
  data = {
    # ******* Do not change below variables. These values are supplied by commonVariables.hcl ***********
    parent_type                                  = "{{.parent_type}}"  
    parent_id                                    = "{{.parent_id}}" 
    billing_account                              = "{{.billing_account}}"
    terraform_state_storage_bucket               = "{{.terraform_state_storage_bucket}}"
    owners_group                                 = "{{.owners_group}}"
    admin_group                                  = "{{.admin_group}}"
    cloud_users_group                            = "{{.cloud_users_group}}"  
    ttw_project_id                               = "{{.ttw_project_id}}"
    ttw_region                                   = "{{.ttw_region}}"  
    vpc_network_name                             = "{{.vpc_network_name}}"
    web_subnet_name                              = "{{.web_subnet_name}}"
    
    # ********** For below variables, default values can be retained. User can change these values based on requirement ***********

    ttw_instance_template_name                   = "ttw-template-1"
    mig_name                                     = "webserver-mig1"
    mig_instance_type                            = "n2d-standard-2"
    
    # ******* Below variable values must be changed by user *****************

    # Format of the mig_distribution_policy_zones variable value should be: "[\"us-central1-f\", \"us-central1-a\",\"us-central1-c\"]". 
    # Zone values depends on region in which assured workload 'three tier workload project' is created. The region should support N2D machine type. Refer README file pre-requisite to see supported regions for N2D machine type.
    mig_distribution_policy_zones                = ""


    # ********** For below variables, default values can be retained. User can change these values based on requirement ***********
    
    autoscaling_min_replicas                     = 2
    autoscaling_max_replicas                     = 3
    autoscaling_cooldown_period                  = 120
    autoscaling_cpu_utilization                  = 0.6
    mig_instance_datatype_label                  = "client"
    mig_instance_data_criticality_label          = "high"

    # ******* Below variable values must be changed and should be globally unique ***********

    # Format of the load_balancer_ssl_certificate_domain_name should be "example.us.", "example.dev."
    load_balancer_ssl_certificate_domain_name    = ""
    # Globally unique bucket name. Example: "example-loadbalancer-bucket"
    loadbalancer_backend_bucket_name             = ""
    # Format of the load_balancer_url_map_host should be "example.us", "example.dev". User can change host map as required.
    load_balancer_url_map_host                   = ""

    # ******* Below variable values must be changed by user *****************
    
    # Loadbalancer traffic distribution paths based on user request URL. Example "/web*", "/static". Should be changed based on application deployed in webserver and backend bucket file.
    load_balancer_url_map_compute_backend_path   = "/"
    load_balancer_url_map_bucket_backend_path    = "/static"
    
    # ********** For below variables, default values can be retained. User can change these values based on requirement. *************

    backend_mig_protocol                         = "HTTP"
    backend_mig_timeout                          = 30
    ttw_compute_http_health_check_name           = "ttw-http-health-check"
    ttw_compute_http_health_check_timeout_sec    = 30
    ttw_compute_http_health_check_interval_sec   = 30
    ttw_compute_http_health_check_healthy_threshold = 2
    ttw_compute_http_health_check_unhealthy_threshold = 2
    ttw_compute_http_health_check_request_path   = "/"
    ttw_compute_http_health_check_response       = ""
    ttw_compute_http_health_check_proxy_header   = "NONE"
    cloud_armor_security_policy_name             = "cloud-armor-security-policy"

    # ******** Below variable value must be changed as per your network design. ***********

    cloud_armor_security_policy_allow_range      = "34.93.96.21/32"
  }
}

template "backend" {
  recipe_path = "./gke-sql.hcl"
  data = {
    # ******* Do not change below variables. These values are supplied by commonVariables.hcl ***********
    parent_type                                  = "{{.parent_type}}"  
    parent_id                                    = "{{.parent_id}}" 
    billing_account                              = "{{.billing_account}}"
    terraform_state_storage_bucket               = "{{.terraform_state_storage_bucket}}"
    owners_group                                 = "{{.owners_group}}"
    admin_group                                  = "{{.admin_group}}"
    cloud_users_group                            = "{{.cloud_users_group}}"  
    ttw_project_id                               = "{{.ttw_project_id}}"
    ttw_region                                   = "{{.ttw_region}}"
    vpc_network_name                             = "{{.vpc_network_name}}"
    web_subnet_name                              = "{{.web_subnet_name}}" 
    web_subnet_ip_range                          = "{{.web_subnet_ip_range}}"
    gke_subnet_name                              = "{{.gke_subnet_name}}"   
    logging_project_id                           = "{{.logging_project_id}}"
    logging_project_region                       = "{{.logging_project_region}}"
    
    # ********** For below variables, default values can be retained. User can change these values based on requirement ***********

    mig_instance_datatype_label                  = "client"
    mig_instance_data_criticality_label          = "high"
    gke_private_cluster_name                     = "ttw-gke-cluster"
    gke_node_pool_name                           = "pool-1"
    gke_node_pool_machine_type                   = "n1-standard-1"
    gke_node_pool_min_instance_count             = 1
    gke_node_pool_max_instance_count             = 2 
    gke_node_pool_instance_disk_size             = 30
    gke_node_pool_image_type                     = "COS"
    private_cloud_sql_name                       = "ttw-sql-instance"
    private_cloud_sql_machine_type               = "db-n1-standard-1"
    ttw_project_log_sink_filter                  = "resource.type = gce_instance AND severity >= WARNING"

    # ******* Below variable value must be changed and should be globally unique *******

    # GLobally unique bucket name. Example: "example-sql-bucket"
    cloud_sql_backup_export_bucket_name          = ""
    
    # ******** Below variable value must be changed as per your network design *******

    gke_private_master_ip_range                  = "192.168.3.0/28"
    
  }
}
