# Force mfa for cli and console:

# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "AllowViewAccountInfo",
#             "Effect": "Allow",
#             "Action": "iam:ListVirtualMFADevices",
#             "Resource": "*"
#         },
#         {
#             "Sid": "AllowManageOwnVirtualMFADevice",
#             "Effect": "Allow",
#             "Action": [
#                 "iam:CreateVirtualMFADevice",
#                 "iam:DeleteVirtualMFADevice"
#             ],
#             "Resource": "arn:aws:iam::*:mfa/${aws:username}"
#         },
#         {
#             "Sid": "AllowManageOwnUserMFA",
#             "Effect": "Allow",
#             "Action": [
#                 "iam:DeactivateMFADevice",
#                 "iam:EnableMFADevice",
#                 "iam:GetUser",
#                 "iam:ListMFADevices",
#                 "iam:ResyncMFADevice"
#             ],
#             "Resource": "arn:aws:iam::*:user/${aws:username}"
#         },
#         {
#             "Sid": "DenyAllExceptListedIfNoMFA",
#             "Effect": "Deny",
#             "NotAction": [
#                 "iam:CreateVirtualMFADevice",
#                 "iam:EnableMFADevice",
#                 "iam:GetUser",
#                 "iam:ListMFADevices",
#                 "iam:ListVirtualMFADevices",
#                 "iam:ResyncMFADevice",
#                 "sts:GetSessionToken"
#             ],
#             "Resource": "*",
#             "Condition": {
#                 "BoolIfExists": {
#                     "aws:MultiFactorAuthPresent": "false"
#                 }
#             }
#         }
#     ]
# }