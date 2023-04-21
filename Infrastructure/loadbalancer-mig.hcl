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
  labels = {
    env = "prod"
  }
}

template "three-tier-workload" {
  recipe_path = "git://github.com/GoogleCloudPlatform/healthcare-data-protection-suite//templates/tfengine/recipes/project.hcl"
  output_path = "./threetierworkload/loadbalancer-mig"
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
       
        
        resource "google_service_account_iam_member" "cloud-users-access-to-service-account" {
            service_account_id = "$${google_service_account.web_server_service_account.name}"
            role               = "roles/iam.serviceAccountUser"
            member             = "group:{{.cloud_users_group}}"
        }

        # User can configure roles with minimum permission as required
#Code Block 3.2.8.a 
        resource "google_project_iam_binding" "loadbalancer_access" {
            project = "{{.ttw_project_id}}"
            role    = "roles/compute.loadBalancerAdmin"

            members = [
                "group:{{.cloud_users_group}}",
            ]
        }
#Code Block 3.2.9.a
        resource "google_project_iam_binding" "cloud_armor_access" {
            project = "{{.ttw_project_id}}"
            role    = "roles/compute.securityAdmin"

            members = [
                "group:{{.cloud_users_group}}",
            ]
        }
#Code Block 3.2.4.a 
        resource "google_project_iam_binding" "compute_access" {
            project = "{{.ttw_project_id}}"
            role    = "roles/compute.instanceAdmin"

            members = [
                "group:{{.cloud_users_group}}",
            ]
        }

       /* data "google_compute_network" "ttw_network_data" {
            name = "{{.vpc_network_name}}"
            project = "{{.ttw_project_id}}"
        }*/
#Code Block 3.2.2.c
        resource "google_project_iam_audit_config" "project" {
            project = "{{.ttw_project_id}}"
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
        resource "google_compute_firewall" "health_check_firewall" {
            name    = "health-checkers-firewall"
            network = "{{.vpc_network_name}}"

            allow {
                protocol = "icmp"
            }

            allow {
                protocol = "tcp"
                ports    = ["80", "8080", "1000-2000"]
            }
            source_ranges = [
                "130.211.0.0/22",
                "35.191.0.0/16"
            ]
            target_tags = ["ttw-health-check"]
            
        }

        resource "google_compute_instance_template" "ttw_webserver_instance_template_region_1" {
            name = "{{.ttw_instance_template_name}}"
            description = "template for DPT FedRAMP"
            region = "{{.ttw_region}}"
            tags = ["ttw-webserver","ttw-health-check"]
            metadata_startup_script = <<SCRIPT
                sudo apt-get -y update
                apt-get install -y apache2 php
                sudo apt-get -y install mysql-client
                SCRIPT
#Code Block 3.2.4.d
            labels = {
              component = "webserver"
              data_type = "{{.mig_instance_datatype_label}}"
              data_criticality = "{{.mig_instance_data_criticality_label}}"
            }

            # Machine type should support confidential compute. Use N2D type instances.
            machine_type  = "{{.mig_instance_type}}"
            can_ip_forward = false
            scheduling {
              automatic_restart   = true
              on_host_maintenance = "TERMINATE"
            }
            disk {
              # This is a basic image, which supports confidential compute.
              # For custom created images, provide image path as required. Custom image should support confidential compute
              source_image =  "projects/confidential-vm-images/global/images/ubuntu-1804-bionic-v20201014"
              auto_delete = true
              boot        = true
              # disk size can be uncommented to customize.
              #disk_size_gb = 
# Code Block 3.2.4.c
              # CMEK disk encription key self link can be provided to the below block
              #disk_encryption_key {
              #     kms_key_self_link = 
              #}
              

            }
            network_interface {
              network = "{{.vpc_network_name}}"
              subnetwork = "{{.web_subnet_name}}"
            }
            service_account {
              email  = "$${google_service_account.web_server_service_account.email}"
              scopes = ["cloud-platform"]
            }
            confidential_instance_config {
                enable_confidential_compute = true
            }
            
        }
        #*****************Managed Instance Group With Autoscaling**************************
        
               
        resource "google_compute_health_check" "ttw-webserver-health-check" {

            name = "{{.ttw_compute_http_health_check_name}}"
            timeout_sec = {{.ttw_compute_http_health_check_timeout_sec}}
            check_interval_sec = {{.ttw_compute_http_health_check_interval_sec}}
            healthy_threshold =  {{.ttw_compute_http_health_check_healthy_threshold}}
            unhealthy_threshold = {{.ttw_compute_http_health_check_unhealthy_threshold}}
            http_health_check {
                  #port_name =
                  #port_specification = "USE_NAMED_PORT"
                  port = 80
                  request_path = "{{.ttw_compute_http_health_check_request_path}}"
                  proxy_header = "{{.ttw_compute_http_health_check_proxy_header}}"
                  response = "{{.ttw_compute_http_health_check_response}}"
            }
        }
        resource "google_compute_region_instance_group_manager" "ttw-webserver-mig1" {
            name = "{{.mig_name}}"
            base_instance_name =  "webserver-mig1-instance"
            # Distribution policy defines in which zones the instances have to distributed.
            # User has to check regions and zones that support N2D machine type (For confidential compute) https://cloud.google.com/compute/docs/regions-zones#available

            distribution_policy_zones  = {{.mig_distribution_policy_zones}}
            depends_on = "$${[google_compute_instance_template.ttw_webserver_instance_template_region_1]}"
            version {
                instance_template = "$${google_compute_instance_template.ttw_webserver_instance_template_region_1.id}"       
            }   
            region = "{{.ttw_region}}"
            project = "{{.ttw_project_id}}" 
            auto_healing_policies {
                health_check = "$${google_compute_health_check.ttw-webserver-health-check.id}"
                initial_delay_sec = 300
                # This is the port number that your backend instances (Compute Engine instances) are listening on
                # If not specified, instances will listen on the same port as loadbalancer listing port.
                #named_port: 
                  #name: "customHTTP"
                  #port: 8080
            }

        }

#Code Block 3.2.4.b 
        resource "google_compute_region_autoscaler" "ttw-webserver-autoscaler" {
            name = "ttw-webserver-autoscaler-1"
            region = "{{.ttw_region}}" 
            target = "$${google_compute_region_instance_group_manager.ttw-webserver-mig1.id}"
            autoscaling_policy {
                max_replicas = {{.autoscaling_max_replicas}}
                min_replicas = {{.autoscaling_min_replicas}}
                cooldown_period = {{.autoscaling_cooldown_period}}
                cpu_utilization {
                  target = {{.autoscaling_cpu_utilization}}
                
                  # uncomment to use autocaling metric instead of CPU utilization
                  #metric{
                      
                  #}
                }
            }
        }
        

        #***********************          Load Balancer                   *****************
#Code Block 3.2.8.b (1)
        resource "google_compute_managed_ssl_certificate" "ttw-ssl-certificate" {
                name = "ttw-cert"
                managed {
                    domains = ["{{.load_balancer_ssl_certificate_domain_name}}"]
                }
        }

        #resource "google_compute_ssl_certificate" "default" {
        #    name_prefix = "my-certificate-"
        #   description = "a description"
        #    private_key = file("path/to/private.key")
        #    certificate = file("path/to/certificate.crt")
        #
        #    lifecycle {
        #        create_before_destroy = true
        #    }
        #}
        resource "google_compute_global_forwarding_rule" "ttw-https-global-forwarding-rule"{
                name = "ttw-https-forwarding-rule"
                target = "$${google_compute_target_https_proxy.ttw-https-target-proxy.id}"
                port_range = "443"
                # Ephemeral IP address will be auto created. Uncomment and provide self link of custom external IP
                # ip_address =
                load_balancing_scheme = "EXTERNAL"
                
        }
        resource "google_compute_target_https_proxy" "ttw-https-target-proxy" {
                name = "ttw-target-proxy"
                url_map = "$${google_compute_url_map.ttw-url-map.id}"
#Code Block 3.2.8.b (2)
#If self-managed certificate is used, change the reference in the below SSL parameter
                ssl_certificates = "$${[google_compute_managed_ssl_certificate.ttw-ssl-certificate.id]}"
        }  
        
        resource "google_compute_url_map" "ttw-url-map" {
                name = "ttw-url-target-proxy"
                default_service = "$${google_compute_backend_service.ttw-backend-service-1.id}"
                host_rule {
                  hosts = ["{{.load_balancer_url_map_host}}"]
                  path_matcher = "backendpath"
                }
                path_matcher{
                  name = "backendpath"
                  default_service = "$${google_compute_backend_service.ttw-backend-service-1.id}"
                  path_rule {
                        paths   = ["{{.load_balancer_url_map_compute_backend_path}}"]
                        service =  "$${google_compute_backend_service.ttw-backend-service-1.id}"
                    }

                    path_rule {
                        paths   = ["{{.load_balancer_url_map_bucket_backend_path}}"]
                        service = "$${google_compute_backend_bucket.ttw-static-website.id}"
                    }
                }
        } 

        resource "google_compute_backend_service" "ttw-backend-service-1" {
                name = "ttw-regional-backend-service"
                backend {
                  group          = "$${google_compute_region_instance_group_manager.ttw-webserver-mig1.instance_group}"
                  balancing_mode = "UTILIZATION"
                  capacity_scaler = 1.0
                }
                protocol = "{{.backend_mig_protocol}}"
                #seconds to wait for the backend before considering it a failed request. Default is 30 seconds. Valid range 
                timeout_sec = {{.backend_mig_timeout}}
                security_policy = google_compute_security_policy.policy.self_link
                #enable_cdn  = false
                health_checks ="$${[google_compute_health_check.ttw-webserver-health-check.id]}"
        }
        
        resource "google_compute_backend_bucket" "ttw-static-website" {
            name        = "static-bucket-backend"
            description = "Contains static files"
            bucket_name = "$${module.ttw_static_files_bucket.bucket.name}"
            enable_cdn  = true
            depends_on = "$${[module.ttw_static_files_bucket]}"
        }
#Code Block 3.2.8.b (3)
 #Customize this code block when using self-managed certificate
        resource "google_dns_record_set" "set" {
                name         = "$${google_dns_managed_zone.ttw-zone.dns_name}"
                type         = "A"
                ttl          = 3600
                managed_zone = "$${google_dns_managed_zone.ttw-zone.name}"
                rrdatas      = "$${[google_compute_global_forwarding_rule.ttw-https-global-forwarding-rule.ip_address]}"
        }
        resource "google_dns_managed_zone" "ttw-zone" {
                name     = "ttw-zone"
                dns_name = "{{.load_balancer_ssl_certificate_domain_name}}"
        }

        # *****************************  Cloud Armor ***************************************
        # This block creates Cloud Armor security policy.
#Code Block 3.2.9.b
        resource "google_compute_security_policy" "policy" {
            name = "{{.cloud_armor_security_policy_name}}cloud-armor-security-policy"
            # Default rule to deny traffic from internet
            rule {
                action   = "deny(403)"
                priority = "2147483647"
                match {
                    versioned_expr = "SRC_IPS_V1"
                    config {
                        src_ip_ranges = ["*"]
                    }
                }
                description = "default rule"
            }
            #user can configure rules to evaluate more preconfigured expressions
            rule {
                action   = "deny(403)"
                priority = "1000"
                match {
                    expr {
                        expression= "evaluatePreconfiguredExpr('xss-canary')"
                    }
                }
                description = "Deny access to XSS attempts"
            }
            # Custom rule to allow specific IPs(allowlist)
            rule {
                action   = "allow"
                priority = "500"
                match {
                    versioned_expr = "SRC_IPS_V1"
                    config {
                        src_ip_ranges = [
                            "{{.cloud_armor_security_policy_allow_range}}"
                        ]
                    }
                }
                description = "allow only from Specific range"
            }
        }
        

      EOF

    }
    resources = {
        service_accounts = [
            {
            account_id   = "web-server-service-account"
            resource_name = "web_server_service_account"
            description  = "web Service Account"
            display_name = "web Service Account"
            }
        ]
        compute_routers = [{
            name    = "ttw-fedramp-router"
            resource_name = "ttw_fedramp_router"
            network = "{{.vpc_network_name}}"
            nats = [{
                name = "ttw-webserver-router-nat"
                source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
                subnetworks = [
                    {
                    name = "{{.web_subnet_name}}"
                    source_ip_ranges_to_nat  = ["ALL_IP_RANGES"]
                    },
                    {
                    name = "{{.gke_subnet_name}}"
                    source_ip_ranges_to_nat  = ["ALL_IP_RANGES"]
                    },
                ]
            }]
        }]
        storage_buckets = [{
            name = "{{.loadbalancer_backend_bucket_name}}"
            resource_name = "ttw_static_files_bucket"
#Code Block 3.2.1.c    
            labels = {
                data_type = "{{.mig_instance_datatype_label}}"
                data_criticality = "{{.mig_instance_data_criticality_label}}"
            }
#Code Block 3.2.1.b
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
#Code Block 3.2.1.a
            iam_members = [{
                role   = "roles/storage.objectCreator"
                member = "group:{{.cloud_users_group}}"
            }]
        }]
    }
  }
}
