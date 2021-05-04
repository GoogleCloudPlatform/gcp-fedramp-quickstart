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

#******************************  Template code starts from here ******************************

data = {
  parent_type     = "{{.parent_type}}"
  parent_id       = "{{.parent_id}}"
  billing_account = "{{.billing_account}}"
  state_bucket    = "{{.terraform_state_storage_bucket}}"
  # Default locations for resources. Can be overridden in individual templates.
  bigquery_location   = "{{.ttw_region}}"
  storage_location    = "{{.ttw_region}}"
  compute_region = "{{.ttw_region}}"
  compute_zone = "a"
  labels = {
    env = "prod"
  }
}

# Resource deployment can be further splitted to group resources and share resource templates.

template "three-tier-workload" {
  recipe_path = "git://github.com/GoogleCloudPlatform/healthcare-data-protection-suite//templates/tfengine/recipes/project.hcl"
  output_path = "./threetierworkload/network"
  data = {
    project = {
      project_id = "{{.ttw_project_id}}"
      exists     = true
      apis = [
            "compute.googleapis.com",
            "iam.googleapis.com",
            "sql-component.googleapis.com",
            "sqladmin.googleapis.com",
            "cloudkms.googleapis.com",
            "dlp.googleapis.com",
            "bigquery.googleapis.com",
            "bigqueryconnection.googleapis.com",
            "bigquerydatatransfer.googleapis.com",
            "bigqueryreservation.googleapis.com",
            "bigquerystorage.googleapis.com",
            "dns.googleapis.com",
            "secretmanager.googleapis.com",
            "servicenetworking.googleapis.com",
            "container.googleapis.com",
            "pubsub.googleapis.com",
            "dataflow.googleapis.com",
			"logging.googleapis.com",
            "monitoring.googleapis.com",
            
      ]
    }
    resources = {

        compute_networks =  [{
            
            name = "{{.vpc_network_name}}" 
            resource_name = "ttw_network"
            # Enabling private Service access
            cloud_sql_private_service_access = {}
            subnets = [
                {
                name="{{.web_subnet_name}}"
                compute_region="{{.ttw_region}}"   
                ip_range="{{.web_subnet_ip_range}}"  

                },
                
                {
                name = "{{.gke_subnet_name}}"
                compute_region = "{{.ttw_region}}"   
                ip_range = "{{.gke_subnet_primary_ip_range}}"
                secondary_ranges = [
                    {
                    name = "gke-subnet-secondary-pod-range"
                    ip_range = "{{.gke_subnet_secondary_pod_ip_range}}"
                    },
                    {
                    name = "gke-subnet-secondary-service-range"
                    ip_range = "{{.gke_subnet_secondary_service_ip_range}}"
                    }
                    
                  ]
                }
            ]   
        }]
    }
  }
}

template "logging" {
  recipe_path = "git://github.com/GoogleCloudPlatform/healthcare-data-protection-suite//templates/tfengine/recipes/project.hcl"
  output_path = "./logging/network"
  data = {
    project = {
      project_id = "{{.logging_project_id}}"
      exists     = true
      apis = [
            "compute.googleapis.com",
            "iam.googleapis.com",
            "servicenetworking.googleapis.com",
			"logging.googleapis.com",
            "stackdriver.googleapis.com",
            "dlp.googleapis.com",
            "bigquery.googleapis.com",
            "bigqueryconnection.googleapis.com",
            "bigquerydatatransfer.googleapis.com",
            "bigqueryreservation.googleapis.com",
            "bigquerystorage.googleapis.com",
            "pubsub.googleapis.com",
            "dataflow.googleapis.com",
            
      ]
    }
    terraform_addons = {
        raw_config = <<EOF

        provider "google" {
            project     = "{{.logging_project_id}}"
            region      = "{{.logging_project_region}}"
        }
        
        provider "google-beta" {
            project     = "{{.logging_project_id}}"
            region      = "{{.logging_project_region}}"
        }
        
        # This firewall rule helps Dataflow worker VMs communicate with each other
        resource "google_compute_firewall" "dataflow_workers_internal_communication_firewall" {
            name    = "dataflow-workers-internal-communication-firewall"
            network = "{{.dataflow_network_name}}"
            project = module.project.project_id
            depends_on = [ module.logging_network, module.cloud_sql_private_service_access_logging_network]
            allow {
                protocol = "icmp"
            }

            allow {
                protocol = "tcp"
                ports    = ["12345-12346"]
            }
            source_ranges = [
                "{{.dataflow_subnet_ip_range}}"
            ]
            target_tags = ["dataflow"]
        }


    EOF
    }
    resources = {
        # Network used by Dataflow workers
        compute_networks =  [{
            
            name = "{{.dataflow_network_name}}" 
            resource_name = "logging_network"
            # Enabling private Service access
            cloud_sql_private_service_access = {}
            subnets = [
                {
                name="{{.dataflow_subnet_name}}"
                compute_region="{{.logging_project_region}}"   
                ip_range="{{.dataflow_subnet_ip_range}}"  
                },
            ]   
        }]
    }
  }
}