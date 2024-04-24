#!/bin/sh

# To use, run: `. ./mfa_aws.sh <6 digit code> <optional:profile>`

mfa_code=$1
aws_profile=$2

if [ -z "${mfa_code}" ]
then
    echo "mfa_code not specified, please input 6 digit code"
    exit 0
fi

if [ -z "${aws_profile}" ]
then
    aws_profile="kaelnomads"
fi

# Assume mfa device is: arn:aws:iam::043038001148:mfa/Alex-device
mfa_serial="arn:aws:iam::043038001148:mfa/Alex-device"

temporary_credentials="$(aws sts get-session-token --serial-number $mfa_serial --profile $aws_profile --token-code $mfa_code)"
# echo $temporary_credentials
access_key_id=$(echo "$temporary_credentials" | grep "AccessKeyId" | sed -n 's/.*"AccessKeyId": "\([^"]*\).*/\1/p')
secret_access_key=$(echo "$temporary_credentials" | grep "SecretAccessKey" | sed -n 's/.*"SecretAccessKey": "\([^"]*\).*/\1/p')
access_token=$(echo "$temporary_credentials" | grep "SessionToken" | sed -n 's/.*"SessionToken": "\([^"]*\).*/\1/p')

export AWS_ACCESS_KEY_ID=$access_key_id
export AWS_SECRET_ACCESS_KEY=$secret_access_key
export AWS_SESSION_TOKEN=$access_token