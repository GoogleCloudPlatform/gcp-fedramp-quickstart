# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.



data = {
  parent_type     = "{{.parent_type}}"
  parent_id       = "{{.parent_id}}"
  billing_account = "{{.billing_account}}"
  state_bucket    = "{{.terraform_state_storage_bucket}}"
  
  # Default locations for resources. Can be overridden in individual templates.
  bigquery_location   = "{{.ttw_region}}"
  #healthcare_location = "us-central1"
  storage_location    = "{{.ttw_region}}"
  compute_region = "{{.ttw_region}}"
  compute_zone = "a"
  cloud_sql_region = "{{.ttw_region}}"
  cloud_sql_zone = "a"
  gke_region = "{{.ttw_region}}"
  labels = {
    env = "prod"
  }
}

template "three-tier-workload" {
  recipe_path = "git://github.com/GoogleCloudPlatform/healthcare-data-protection-suite//templates/tfengine/recipes/project.hcl"
  output_path = "./threetierworkload/gke-sql"
  data = {
    project = {
      project_id = "{{.ttw_project_id}}"
      exists     = true
      apis = [
            "logging.googleapis.com",
            "stackdriver.googleapis.com"            
      ]
    }

    terraform_addons = {
        
        raw_config = <<EOF

        provider "google" {
            project     = "{{.ttw_project_id}}"
            region      = "{{.ttw_region}}"
        }
        
        provider "google-beta" {
            project     = "{{.ttw_project_id}}"
            region      = "{{.ttw_region}}"
        }
#Code Block 3.2.6.a       
        resource "google_project_iam_binding" "gke_access" {
            project = "{{.ttw_project_id}}"
            role    = "roles/container.developer"

            members = [
                "group:{{.cloud_users_group}}",
            ]
        }
#Code Block 3.2.3.a
        resource "google_project_iam_binding" "cloud_sql_access" {
            project = "{{.ttw_project_id}}"
            role    = "roles/cloudsql.editor"

            members = [
                "group:{{.cloud_users_group}}",
            ]
        }

        data "google_pubsub_topic" "logging_pubsub_topic" {
            name = "logging-pubsub-topic"
            project = "{{.logging_project_id}}"

        }  
        
        #********************** Logging Project sink *************************************
#To Backup Audit records in to bigquery and provide capability to process them, this log sink streams logs to logging project
        resource "google_logging_project_sink" "my-sink" {
            name = "my-pubsub-instance-sink"
            destination ="pubsub.googleapis.com/$${data.google_pubsub_topic.logging_pubsub_topic.id}"
            #*** "pubsub.googleapis.com/projects/my-project/topics/instance-activity"
            #uncomment to add filter the logs before sending to logging project
#Code Block 3.2.2.c
            #filter = "{{.ttw_project_log_sink_filter}}"

            # Use a unique writer (creates a unique service account used for writing)
            unique_writer_identity = true
        }

        resource "google_project_iam_binding" "log-writer" {
            project = "{{.logging_project_id}}"
            role = "roles/pubsub.publisher"

            members = [
                google_logging_project_sink.my-sink.writer_identity,
            ]
        }

        
        

      EOF

    }
    resources = {
        cloud_sql_instances = [{
            name               = "{{.private_cloud_sql_name}}"
            resource_name      = "ttw_sql_instance"
            type               = "mysql"
            network_project_id = "{{.ttw_project_id}}"
            network            = "{{.vpc_network_name}}"
            tier               = "{{.private_cloud_sql_machine_type}}"
            labels = {
                component = "database"
                data_type = "{{.mig_instance_datatype_label}}"
                data_criticality = "{{.mig_instance_data_criticality_label}}"
            }
            # At the time of this writing, Secret Manager is not FedRAMP compliant. The following code creates a default user and password.
            #user_name        = "user1"
            #user_password    = "$${data.google_secret_manager_secret_version.db_password.secret_data}"
        }]
        # Storage bucket used to export 
        storage_buckets = [{
            name = "{{.cloud_sql_backup_export_bucket_name}}"
            resource_name = "ttw_cloud_sql_backup_export_bucket"
            labels = {
                data_type = "{{.mig_instance_datatype_label}}"
                data_criticality = "{{.mig_instance_data_criticality_label}}"
            }
            #  Use this code block as an example to add a life cycle policy. This can be customized to match required action
            #lifecycle_rules = [{
            #    action = {
            #        type          = 
            #        storage_class = 
            #    }
            #    condition = {
            #        age                   = 
            #        matches_storage_class = 
            #    }
            #}]
            iam_members = [{
                role   = "roles/storage.objectCreator"
                member = "group:{{.cloud_users_group}}"
            }]
        }]
        gke_clusters = [{
            name                   = "{{.gke_private_cluster_name}}"
            resource_name          = "ttw_gke-cluster"
            network_project_id     = "{{.ttw_project_id}}"
            network                = "{{.vpc_network_name}}"
            subnet                 = "{{.gke_subnet_name}}"  
            ip_range_pods_name     = "gke-subnet-secondary-pod-range"
            ip_range_services_name = "gke-subnet-secondary-service-range"
            master_ipv4_cidr_block = "{{.gke_private_master_ip_range}}"
#Code Block 3.2.6.c
            node_pools = [
                {
                name              = "{{.gke_node_pool_name}}"
                machine_type      = "{{.gke_node_pool_machine_type}}"
                min_count         = {{.gke_node_pool_min_instance_count}}
                max_count         = {{.gke_node_pool_max_instance_count}}
                disk_size_gb      = {{.gke_node_pool_instance_disk_size}}
                #Uncomment the following parameters to customize node pool
                #disk_type         = 
                #accelerator_count = 
                #accelerator_type  = 
                image_type        = "{{.gke_node_pool_image_type}}"
                #uncomment to enable auto_repair. Default is false
                #auto_repair       = true
                auto_upgrade    = true
               }
            ]
#Code Block 3.2.6.b (1)              
            master_authorized_networks = [
            {
                cidr_block = "{{.web_subnet_ip_range}}"
                display_name = "web-subnet"

            }
#Code Block 3.2.6.b (2)            
            # Uncomment to whitelist additional IPs.
           #{
                #cidr_block = ""
                #display_name = ""
           #}
            ]
#Code Block 3.2.6.d
            labels = {
                component = "application-server"
                data_type = "{{.mig_instance_datatype_label}}"
                data_criticality = "{{.mig_instance_data_criticality_label}}"
            }
        }]
            
        
    }
  }
}