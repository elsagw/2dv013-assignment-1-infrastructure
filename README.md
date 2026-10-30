# Assignment: Infrastructure

Provisionerar två servrar på Cumulus (OpenStack) via Terraform/OpenTofu och konfigurerar dem via Ansible: en `webapp`-server (Flask-app på port 8080) och en `database`-server (PostgreSQL), som kommunicerar över det privata nätverket.

## Starta repot

1. Source:a dina OpenStack-credentials:
   ```
   source eg223ps-2dv013-ht25-openrc.sh
   ```
2. Exportera din keypair:
   ```
   export TF_VAR_key_name=<ditt-keypair-namn-på-cumulus>
   export TF_VAR_identity_file=<sökväg-till-din-.pem-fil>
   ```
3. Kör deploy-skriptet från projektets rot:
   ```
   ./deploy.sh
   ```
   Detta installerar Ansible-collections, initierar Terraform och provisionerar/konfigurerar infrastrukturen. Skriptet skriver ut den publika IP-adressen till webappen samt serrarnas privata IP-adresser.

## Riva ner infrastrukturen

```
cd terraform
tofu destroy
```
