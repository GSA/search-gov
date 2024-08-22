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
    # Exclude parameters that start with "DEPLOY_" or match "*_EC2_PEM_KEY"
    if [[ $PARAM != DEPLOY_* && ! $PARAM =~ .*_EC2_PEM_KEY$ ]]; then
        # Fetch the parameter value from SSM
        VALUE=$(aws ssm get-parameter --name "$PARAM" --with-decryption --query "Parameter.Value" --output text)
        
        # If using a path, remove the path from the parameter name (not needed here, since no path)
        if [ -n "$PARAM_PATH" ]; then
            PARAM=$(echo "$PARAM" | sed "s|$PARAM_PATH||g")
        fi

        # Write the key=value pair to the .env file
        echo "$PARAM=$VALUE" >> .env
    fi
done

# Output the result
echo ".env file created with the following content:"
cat .env
cp /home/search/cicd_temp/.env /home/search
