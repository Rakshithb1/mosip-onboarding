#!/bin/sh
export MYDIR=$(pwd)

# Load variables from properties file
PROPERTIES_FILE="esignet-misp.properties"

# Function to read properties file
get_property() {
    grep "^$1=" "$PROPERTIES_FILE" | cut -d'=' -f2-
}

# Assigning values
URL=$(get_property "URL")
ESIGNET_URL=$(get_property "ESIGNET_URL")
PARTNER_MANAGER_USERNAME=$(get_property "PARTNER_MANAGER_USERNAME")
PARTNER_MANAGER_PASSWORD=$(get_property "PARTNER_MANAGER_PASSWORD")
MODULE_SECRETKEY=$(get_property "MODULE_SECRETKEY")
POLICY_GROUP_NAME=$(get_property "POLICY_GROUP_NAME")
PARTNER_KC_USERNAME=$(get_property "PARTNER_KC_USERNAME")
PARTNER_ORGANIZATION_NAME=$(get_property "PARTNER_ORGANIZATION_NAME")
POLICY_NAME=$(get_property "POLICY_NAME")

create_misp_and_licensekey() {
    echo "Onboarding MISP partner and generating license key"
    reports_dir="./reports/custom-scripts/$(date +%Y%m%d%H%M%S)"
    mkdir -p "$reports_dir"

    newman run custom-scripts.postman_collection.json -e custom-scripts.postman_environment.json \
    --env-var url="$URL" \
    --env-var esignet-url="$ESIGNET_URL" \
    --env-var partner-manager-username="$PARTNER_MANAGER_USERNAME" \
    --env-var partner-manager-password="$PARTNER_MANAGER_PASSWORD" \
    --env-var application-id=partner \
    --env-var module-clientid=mosip-pms-client \
    --env-var module-secretkey="$MODULE_SECRETKEY" \
    --env-var policy-group-name="$POLICY_GROUP_NAME" \
    --env-var partner-kc-username="$PARTNER_KC_USERNAME" \
    --env-var partner-organization-name="$PARTNER_ORGANIZATION_NAME" \
    --env-var partner-type=MISP_Partner \
    --env-var policy-name="$POLICY_NAME" \
    --env-var partner-domain=MISP \
    --folder 'create/publish_policy_group_and_policy' \
    --folder partner-self-registration \
    --folder download-esignet-root-certificate \
    --folder download-esignet-leaf-certificate \
    --folder download-esignet-partner-certificate \
    --folder authenticate-to-upload-certs \
    --folder upload-ca-certificate \
    --folder upload-intermediate-ca-certificate \
    --folder upload-leaf-certificate \
    --folder activate-partner \
    --folder upload-signed-esignet-certificate \
    --folder partner_request_mapping_to_policyname \
    --folder approve-partner-mapping-to-policy \
    --folder create-the-MISP-license-key-for-partner \
    -d ./custom-esignet-misp-policy.json \
    -r cli,htmlextra --reporter-htmlextra-export "$reports_dir/esignet.html" --reporter-htmlextra-showEnvironmentData
}

create_misp_and_licensekey

PROPERTIES_FILE="esignet-oidc.properties"

# Function to read properties file
get_property() {
    grep "^$1=" "$PROPERTIES_FILE" | cut -d'=' -f2-
}

# Assigning values
POLICY_GROUP_NAME=$(get_property "POLICY_GROUP_NAME")
PARTNER_KC_USERNAME=$(get_property "PARTNER_KC_USERNAME")
export PARTNER_KC_USERNAME
PARTNER_ORGANIZATION_NAME=$(get_property "PARTNER_ORGANIZATION_NAME")
POLICY_NAME=$(get_property "POLICY_NAME")
root_cert_path="$MYDIR/custom-certs/$PARTNER_KC_USERNAME/RootCA.pem"
client_cert_path="$MYDIR/custom-certs/$PARTNER_KC_USERNAME/Client.pem"
OIDC_CLIENT_NAME=$(get_property "OIDC_CLIENT_NAME")
LOGO_URI=$(get_property "LOGO_URI")
REDIRECT_URIS=$(get_property "REDIRECT_URIS")
create_partner_and_onboard_oidc() {
    echo "Onboarding the Auth_Partner and generating OIDC client"
    reports_dir="./reports/custom-scripts/$(date +%Y%m%d%H%M%S)"
    mkdir -p "$reports_dir"
    sh $MYDIR/custom-certs/create-signing-certs.sh $MYDIR
    	root_ca_cert=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' $root_cert_path)
    	partner_cert=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' $client_cert_path)
    newman run custom-scripts.postman_collection.json  -e custom-scripts.postman_environment.json  \
      --env-var url="$URL" \
      --env-var esignet-url="$ESIGNET_URL" \
      --env-var partner-manager-username="$PARTNER_MANAGER_USERNAME" \
      --env-var partner-manager-password="$PARTNER_MANAGER_PASSWORD" \
      --env-var application-id=partner \
    	--env-var module-clientid=mosip-pms-client \
    	--env-var module-secretkey=$MODULE_SECRETKEY \
    	--env-var policy-group-name=$POLICY_GROUP_NAME \
    	--env-var partner-kc-username=$PARTNER_KC_USERNAME \
    	--env-var partner-organization-name=$PARTNER_ORGANIZATION_NAME \
      --env-var partner-type=Auth_Partner \
      --env-var external-url=$EXTERNAL_URL \
    	--env-var policy-name=$POLICY_NAME \
    	--env-var logo-uri=$LOGO_URI \
    	--env-var redirect-uris=$REDIRECT_URIS \
    	--env-var partner-domain=Auth \
    	--env-var ca-certificate="$root_ca_cert" \
    	--env-var leaf-certificate="$partner_cert" \
    	--env-var oidc-client-name="$OIDC_CLIENT_NAME" \
    	--env-var oidc-clientid="$OIDC_CLIENTID" \
    --folder 'create/publish_policy_group_and_policy' \
    --folder partner-self-registration \
    --folder authenticate-to-upload-certs \
    --folder upload-ca-certificate \
    --folder upload-leaf-certificate \
    --folder activate-partner \
    --folder partner_request_mapping_to_policyname \
    --folder approve-partner-mapping-to-policy \
    --folder get-jwks \
    --folder create-oidc-client \
    --folder create-oidc-client-through-esignet \
	  -d ./custom-oidc-auth-policy.json \
    -r cli,htmlextra --reporter-htmlextra-export "$reports_dir/oidc.html" --reporter-htmlextra-showEnvironmentData
}

create_partner_and_onboard_oidc