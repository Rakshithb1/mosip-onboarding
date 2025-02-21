# Custom-Scripts
  Objective:
  The script is able to automate a flow of requests through postman using newman tool . 
# Pre-Requisites:
  The eSignet-oidc.properties contains the details of the auth-partner and oidc client.
  The esignet-misp.properties contains the details of the MISP partner and license key
  Both of these need to be filled before running the script
  
  Also below npm packages are needed to be downloaded
  pem-jwk,newman,newman-reporter-htmlextra
  through npm install -g npm newman newman-reporter-htmlextra pem-jwk