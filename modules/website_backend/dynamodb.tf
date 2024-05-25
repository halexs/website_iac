# DB is too overkill

# resource "aws_dynamodb_table" "location" {
#   name           = "Location"
#   billing_mode   = "PAY_PER_REQUEST" # PROVISIONED
#   read_capacity  = 1
#   write_capacity = 1
#   hash_key       = "Location"
#   range_key      = "MoveInDate"

#   attribute {
#     name = "Location"
#     type = "S"
#   }

#   attribute {
#     name = "MoveInDate"
#     type = "S"
#   }

#   attribute {
#     name = "MoveOutDate"
#     type = "S"
#   }

#   attribute {
#     name = "Coordinates"
#     type = "S"
#   }

#   ttl {
#     attribute_name = "TimeToExist"
#     enabled        = false
#   }

#   global_secondary_index {
#     name               = "GameTitleIndex"
#     hash_key           = "GameTitle"
#     range_key          = "TopScore"
#     write_capacity     = 10
#     read_capacity      = 10
#     projection_type    = "INCLUDE"
#     non_key_attributes = ["UserId"]
#   }

#   tags = {
#     Name        = "location-db"
#     Environment = "dev"
#   }
# }