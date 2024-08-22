#!/bin/bash
set -x
# Move to a writable location
cd /home/search/cicd_temp 

# Leave PARAM_PATH empty to fetch all parameters in the region
PARAM_PATH=""

# Clear the .env file if it exists
> .env

echo "Starting the script"
# Fetch all parameter names in the region
if [ -n "$PARAM_PATH" ]; then
    PARAM_KEYS=$(aws ssm get-parameters-by-path --path "$PARAM_PATH" --region us-east-2 --recursive --query "Parameters[*].Name" --output text)
else
    PARAM_KEYS=$(aws ssm describe-parameters --region us-east-2 --query "Parameters[*].Name" --output text)
fi
echo "Fetched parameter keys: $PARAM_KEYS"

# Loop through each parameter key
for PARAM in $PARAM_KEYS; do
    # Exclude parameters that start with "DEPLOY_" or match "*_EC2_PEM_KEY" or match LOGIN_DOT_GOV_PEM
    if [[ $PARAM != DEPLOY_* && ! $PARAM =~ .*_EC2_PEM_KEY$ && $PARAM != "LOGIN_DOT_GOV_PEM" ]]; then
        # Fetch the parameter value from SSM
        VALUE=$(aws ssm get-parameter --name "$PARAM" --with-decryption --query "Parameter.Value" --output text)
        
        # Rename parameters that start with "SEARCH_AWS_" to "AWS_"
        if [[ $PARAM == SEARCH_AWS_* ]]; then
            PARAM=${PARAM/SEARCH_AWS_/AWS_}
        fi

        # Write the key=value pair to the .env file
        echo "$PARAM=$VALUE" >> .env
    fi
done

# Output the result
echo ".env file created with the following content:"
cat .env
cp /home/search/cicd_temp/.env /home/search/searchgov/shared

# Fetch a specific parameter and save it to a file
aws ssm get-parameter --name "LOGIN_DOT_GOV_PEM" --region us-east-2 --with-decryption --query "Parameter.Value" --output text > /home/search/searchgov/logindotgov.pem
