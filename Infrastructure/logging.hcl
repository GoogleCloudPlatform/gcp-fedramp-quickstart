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
  bigquery_location   = "{{.logging_project_region}}"
  storage_location    = "{{.logging_project_region}}"
  compute_region = "{{.logging_project_region}}"
  compute_zone = "a"
  labels = {
    env = "prod"
  }
}

template "logging" {
  recipe_path = "git://github.com/GoogleCloudPlatform/healthcare-data-protection-suite//templates/tfengine/recipes/project.hcl"
  output_path = "./logging/workload"
  data = {
    project = {
      project_id = "{{.logging_project_id}}"
      exists     = true
      apis = [
			"monitoring.googleapis.com",
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

        data "google_project" "project_number" {
			project_id  = module.project.project_id
		}

#Code Block 3.2.2.c
        resource "google_project_iam_audit_config" "project" {
            project = module.project.project_id
            service = "allServices"
            audit_log_config {
                log_type = "DATA_READ"
            }
            audit_log_config {
                log_type = "DATA_WRITE"
            }
            audit_log_config {
                log_type = "ADMIN_READ"
            }
        }

        resource "google_bigquery_table" "logs_table" {
            dataset_id = "$${module.log_analysis_dataset.bigquery_dataset.dataset_id}"
            table_id = "{{.logs_storage_bigquery_table_name}}"
            project = module.project.project_id
            labels = {
                data_type = "{{.logs_streaming_pubsub_topic_datatype_label}}"
                data_criticality = "{{.logs_streaming_pubsub_topic_data_criticality_label}}"
            }
            # Uncomment and provide schema file path. If left unchanges, this will create an empty table.
            # Schema also can be given inline.
            #schema = file("/{replace with file path}/schema.json")
            
            
        }
        
        resource "google_dataflow_job" "psto_bq_job" {
            name  = "{{.data_flow_job_name}}"
            max_workers = {{.data_flow_job_max_workers}}
            on_delete = "cancel"
            project = module.project.project_id
            network               = "{{.dataflow_network_name}}"
            subnetwork            = "regions/{{.logging_project_region}}/subnetworks/{{.dataflow_subnet_name}}"
            ip_configuration      = "WORKER_IP_PRIVATE"
            region                = "{{.logging_project_region}}"
            depends_on = [google_project_iam_binding.data_flow_service_account_access_worker ]
            template_gcs_path = "gs://dataflow-templates-us-central1/latest/PubSub_Subscription_to_BigQuery"
            temp_gcs_location = "$${module.dataflow_temp_storage_bucket.bucket.url}"
            service_account_email = "$${google_service_account.data_flow_job_service_account.email}"
#Code Block 3.2.7.b            
            labels = {
                data_type = "{{.logs_streaming_pubsub_topic_datatype_label}}"
                data_criticality = "{{.logs_streaming_pubsub_topic_data_criticality_label}}"
            }
            parameters = {
                inputSubscription = module.logging_pubsub_topic.subscription_paths[0]
                outputTableSpec = "$${google_bigquery_table.logs_table.project}:$${google_bigquery_table.logs_table.dataset_id}.$${google_bigquery_table.logs_table.table_id}"
                #*****"$${google_bigquery_table.logs_table.project}:$${google_bigquery_table.logs_table.dataset_id}.$${google_bigquery_table.logs_table.table_id}"          
            }
        }
#Code Block 3.2.5.a
        resource "google_project_iam_binding" "pub_sub_access" {
            project = module.project.project_id
            role    = "roles/pubsub.editor"

            members = [
                "group:{{.cloud_users_group}}",
            ]
        }

#Code Block 3.2.7.a
        resource "google_project_iam_binding" "data_flow_access" {
            project = module.project.project_id
            role    = "roles/dataflow.developer"

            members = [
                "group:{{.cloud_users_group}}",
            ]
        }
        #Access given to dataflow service account to write data to bigquery
        resource "google_bigquery_dataset_access" "data_flow_service_account_access_bigquery" {
            dataset_id    = "$${module.log_analysis_dataset.bigquery_dataset.dataset_id}"
            role          = "roles/bigquery.dataEditor"
            user_by_email = google_service_account.data_flow_job_service_account.email
        }
        # Access given to dataflow service account to write to temp storage bucket
        resource "google_storage_bucket_iam_binding" "data_flow_service_account_access_bucket" {
            bucket = "$${module.dataflow_temp_storage_bucket.bucket.name}"
            role = "roles/storage.objectCreator"
            members = [
                "serviceAccount:$${google_service_account.data_flow_job_service_account.email}",
            ]
        }
        # This access is necessary for a Compute Engine service account to execute work units for an Apache Beam pipeline
        resource "google_project_iam_binding" "data_flow_service_account_access_worker" {
            project = module.project.project_id
            role    = "roles/dataflow.worker"

            members = [
                "serviceAccount:$${google_service_account.data_flow_job_service_account.email}",
            ]
        }
        # PubSub subscriber access to dataflow service service account used by worker VMs to pull and acknowledge the messages
        # PubSub subscriber access to dataflow service agent to pull and acknowledge the messages
        resource "google_pubsub_topic_iam_binding" "data_flow_service_account_access_subscriber" {
            project = module.project.project_id
            topic = module.logging_pubsub_topic.topic
            role = "roles/pubsub.subscriber"
            members = [
                "serviceAccount:$${google_service_account.data_flow_job_service_account.email}",
                "serviceAccount:service-$${data.google_project.project_number.number}@dataflow-service-producer-prod.iam.gserviceaccount.com",
            ]
        }
                 
    
    EOF
    }
    resources = {
        service_accounts = [
            {
            account_id   = "data-flow-job-service-account"
            resource_name = "data_flow_job_service_account"
            description  = "web Service Account"
            display_name = "web Service Account"
            } 
        ]
        pubsub_topics = [{
          name = "{{.logs_streaming_pubsub_topic_name}}"
#Code Block 3.2.5.b
          labels = {
              data_type = "{{.logs_streaming_pubsub_topic_datatype_label}}"
              data_criticality = "{{.logs_streaming_pubsub_topic_data_criticality_label}}"
          }
          pull_subscriptions = [
              {
                  name = "{{.logs_streaming_pubsub_subscription_name}}"
                  ack_deadline_seconds = {{.logs_streaming_pubsub_subscription_acknowledgmenet_seconds}}
              }
          ]
        }]
        storage_buckets = [{
            name = "{{.dataflow_temp_storage_bucket_name}}"
            resource_name = "dataflow_temp_storage_bucket"
            labels = {
                data_type = "{{.dataflow_temp_storage_bucket_datatype_label}}"
                data_criticality = "{{.dataflow_temp_storage_bucket_data_criticality_label}}"
            }
            iam_members = [
              {
                role   = "roles/storage.objectViewer"
                member = "group:{{.cloud_users_group}}"
              }
            ]
        }]
        bigquery_datasets = [{
            # Override Terraform resource name as it cannot start with a number.
            resource_name               = "log_analysis_dataset"
            dataset_id                  = "{{.logs_storage_bigquery_dataset_name}}"
#Code Block 3.2.2.d        
            # Retains log records for 90 days. Can be customized to retain for longer period
            default_table_expiration_ms = 7.776e+9
            #depends_on = ["$${module.project-services}"]
#Code Block 3.2.2.b 
            labels = {
                data_type = "{{.logs_streaming_pubsub_topic_datatype_label}}"
                data_criticality = "{{.logs_streaming_pubsub_topic_data_criticality_label}}"
            }
#Code Block 3.2.2.a
            access = [
            {
                role          = "roles/bigquery.dataOwner"
                special_group = "projectOwners"
            },
            {
                role           = "roles/bigquery.dataViewer"
                group_by_email = "{{.cloud_users_group}}"
            }
            ]
        }]
    
    }
   

  }
}
