#!/bin/bash

PROFILE=$HOME/.profile
REGION=$(ec2metadata --availability-zone | sed 's/.$//')

PARAMS="
  ES_HOSTS
  ES_USER
  ES_PASSWORD
  SEARCHELASTIC_INDEX
"

for PARAM in $PARAMS; do
    RAW_VALUE=$(aws ssm get-parameter --name $PARAM --query "Parameter.Value" --output text --region $REGION --with-decryption)

    if [[ -z "$RAW_VALUE" ]]; then
        echo "ERROR! Could not retrive value from param store for $PARAM"
        exit 1
    fi

    if [[ $PARAM == "ES_HOSTS" ]]; then
        VALUE=$(echo $RAW_VALUE | tr -d '[:blank:]|[\"\[\]]')
    else
        VALUE=$RAW_VALUE
    fi
    EXPORT_STATEMENT="export $PARAM=${VALUE}"

    if grep -q "^export $PARAM=" $PROFILE; then
        sed -i "s|^export $PARAM=.*|${EXPORT_STATEMENT}|" $PROFILE
    else
        echo "$EXPORT_STATEMENT" >> $PROFILE
    fi

    # Apply changes for the current session and verify
    source $PROFILE
    if [[ "$(eval echo \"\$$PARAM\")" != "$(sed -e 's/^"//' -e 's/"$//' <<< "$VALUE")" ]]; then
            echo "ERROR! Value for $PARAM not set properly"
        exit 2
    fi

    echo "Successfully feteched and exported $PARAM from parameter store"
done

if [[ -z "$ES_HOSTS" || -z "$ES_USER" || -z "$ES_PASSWORD" || -z "$SEARCHELASTIC_INDEX" ]]; then
  echo "Error: One or more required environment variables are not set"
  echo "Please ensure ES_HOSTS, ES_USER, ES_PASSWORD, and SEARCHELASTIC_INDEX are exported"
  exit 1
fi

INDEX_NAME="$SEARCHELASTIC_INDEX"
TEMPLATE_NAME="${INDEX_NAME}_template"
INDEX_PATTERN="${INDEX_NAME}*"

echo "Elasticsearch Host: $ES_HOSTS"
echo "Index Name: $INDEX_NAME"
echo "Template Name: $TEMPLATE_NAME"
echo "--------------------------"
echo

echo "[Step 1/2] Checking for index '$INDEX_NAME'..."

INDEX_STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X HEAD -u "$ES_USER:$ES_PASSWORD" "$ES_HOSTS/$INDEX_NAME")

if [ "$INDEX_STATUS_CODE" -eq 200 ]; then
  echo "Result: Index '$INDEX_NAME' already exists. Skipping creation."
else
  echo "Result: Index '$INDEX_NAME' does not exist. Creating..."
  
  # Send a PUT request with the mapping to create the index.
  # Using a heredoc (<<EOF) to pass the JSON payload.
  curl -s -X PUT -u "$ES_USER:$ES_PASSWORD" "$ES_HOSTS/$INDEX_NAME" -H 'Content-Type: application/json' --data-binary @- <<EOF
{
  "mappings": {
    "properties": {
      "domain_name": {
        "type": "text",
        "analyzer": "domain_name_analyzer",
        "fields": {
          "keyword": {
            "type": "keyword"
          }
        }
      }
    }
  }
}
EOF
  echo
  echo "Success: Index '$INDEX_NAME' created."
fi

echo

echo "[Step 2/2] Checking for index template '$TEMPLATE_NAME'..."

TEMPLATE_STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X HEAD -u "$ES_USER:$ES_PASSWORD" "$ES_HOSTS/_template/$TEMPLATE_NAME")

if [ "$TEMPLATE_STATUS_CODE" -eq 200 ]; then
  echo "Result: Index template '$TEMPLATE_NAME' already exists. Skipping creation."
else
  echo "Result: Index template '$TEMPLATE_NAME' does not exist. Creating..."
  
  curl -s -X PUT -u "$ES_USER:$ES_PASSWORD" "$ES_HOSTS/_template/$TEMPLATE_NAME" -H 'Content-Type: application/json' --data-binary @- <<EOF
{
  "index_patterns": ["$INDEX_PATTERN"],
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 1
  },
  "mappings": {
    "properties": {
      "domain_name": {
        "type": "text",
        "analyzer": "domain_name_analyzer",
        "fields": {
          "keyword": {
            "type": "keyword"
          }
        }
      }
    }
  }
}
EOF
  echo
  echo "Success: Index template '$TEMPLATE_NAME' created."
fi

echo
echo "--- Setup Complete ---"
