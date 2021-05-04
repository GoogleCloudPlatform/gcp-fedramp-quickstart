# Three-Tier Architecture Use Case Description

[Use Case Description](#use-case-description)

## Use Case Description

* The use case addresses a 3-tier architecture based application deployment on the Google Cloud Platform (GCP) and aligns to FedRAMP standard
* The use case architecture takes into consideration deployment of resources for web-server, application server, and data storage on GCP

## Considerations

* The use case infrastructure will be deployed under the Google Assured Workload
* Based on the availability, the architecture leverages FedRAMP High and Moderate compliant GCP products 
* [Data Protection Toolkit](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite) (DPT) will be leveraged and templates will be shared as HCL scripts
* To deploy web and application servers, customers can leverage the templates provided 
* For FedRAMP compliance, customers can deploy FedRAMP compliant third-party solutions such as Privileged Access Management (e.g., for Application Layer Administrator Access) and Vulnerability Scanner (e.g., Tenable/Nessus)
* For overall FedRAMP compliance, the architecture assumes that the customer will be responsible for the web and application servers including the use of FedRAMP compliant third-party tools such as Security Information and Event Management (SIEM), Privileged Access Management (PAM), Vulnerability Scanner, Compliance / Configuration Management
* Logging data will be in the standard format and can be exported and ingested in a SIEM by the customer when required

