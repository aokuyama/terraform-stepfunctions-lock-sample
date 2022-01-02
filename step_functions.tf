resource "aws_sfn_state_machine" "app" {
  name = "state_lock-sample"

  role_arn = aws_iam_role.state_machine.arn
  definition = jsonencode(
    {
      "StartAt" : "Lock",
      "States" : {
        "Lock" : {
          "Type" : "Task",
          "Resource" : "arn:aws:states:::dynamodb:putItem",
          "Parameters" : {
            "TableName" : aws_dynamodb_table.app.name,
            "Item" : {
              "name" : {
                "S" : "session_a"
              },
              "state" : {
                "S" : "locked"
              }
            },
            "Expected" : {
              "state" : {
                "Exists" : false
              }
            }
          },
          "Next" : "Success"
        },
        "Success" : {
          "Type" : "Succeed"
        }
      }
    }
  )
}
resource "aws_iam_role" "state_machine" {
  path = "/service-role/"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "states.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  managed_policy_arns = [
    aws_iam_policy.dynamodb.arn,
  ]
}
resource "aws_iam_policy" "dynamodb" {
  path = "/service-role/"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "SpecificTable",
          "Effect" : "Allow",
          "Action" : [
            "dynamodb:BatchGet*",
            "dynamodb:DescribeStream",
            "dynamodb:DescribeTable",
            "dynamodb:Get*",
            "dynamodb:Query",
            "dynamodb:Scan",
            "dynamodb:BatchWrite*",
            "dynamodb:CreateTable",
            "dynamodb:Delete*",
            "dynamodb:Update*",
            "dynamodb:PutItem"
          ],
          "Resource" : aws_dynamodb_table.app.arn
        }
      ]
    }
  )
}
