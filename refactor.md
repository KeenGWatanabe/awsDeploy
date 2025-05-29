I'll help you refactor your setup to use AWS Secrets Manager for the MongoDB connection string instead of the .env file. Here's how we'll approach this:

### 1. First, let's modify the g4app application code

You'll need to update your `app.js` or `connect.js` to fetch the secret from AWS Secrets Manager. Here's how to modify it:

```javascript
// In your connect.js (or create a new secrets.js utility file)
const { SecretsManager } = require('aws-sdk');

async function getMongoUri() {
  // If we're in development, still allow .env for local testing
  if (process.env.NODE_ENV === 'development') {
    return process.env.MONGO_URI;
  }

  const secretName = "YOUR_SECRET_NAME"; // The name you used in tf-secrets
  const client = new SecretsManager({
    region: "us-east-1" // Or your preferred region
  });

  try {
    const data = await client.getSecretValue({ SecretId: secretName }).promise();
    if ('SecretString' in data) {
      return JSON.parse(data.SecretString).MONGO_URI;
    }
    throw new Error("Secret binary not supported");
  } catch (err) {
    console.error("Error retrieving secret:", err);
    throw err;
  }
}

module.exports = { getMongoUri };
```

Then update your database connection code to use this:

```javascript
const { getMongoUri } = require('./secrets'); // or wherever you put the above code

async function connectToDatabase() {
  try {
    const mongoUri = await getMongoUri();
    await mongoose.connect(mongoUri, {
      useNewUrlParser: true,
      useUnifiedTopology: true
    });
    console.log("Connected to MongoDB");
  } catch (err) {
    console.error("Database connection error:", err);
    process.exit(1);
  }
}
```

### 2. Update your Dockerfile

Make sure your Dockerfile includes the AWS SDK:

```dockerfile
FROM node:14

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install
# Make sure aws-sdk is installed
RUN npm install aws-sdk

COPY . .

EXPOSE 3000

CMD ["node", "app.js"]
```

### 3. Update your ECS task definition in g4infra

In your `g4infra` repo, modify the task definition to include secrets permissions. Here's an example Terraform snippet:

```hcl
resource "aws_ecs_task_definition" "app" {
  family                   = "g4app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = "g4app"
    image     = "${aws_ecr_repository.g4app.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
    environment = [
      {
        name  = "NODE_ENV",
        value = "production"
      }
    ]
    secrets = [
      {
        name      = "MONGO_URI",
        valueFrom = "arn:aws:secretsmanager:us-east-1:YOUR_AWS_ACCOUNT:secret:YOUR_SECRET_NAME"
      }
    ]
  }])
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role-g4app"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "secrets_access" {
  name = "secrets-access-policy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = [
        "arn:aws:secretsmanager:us-east-1:YOUR_AWS_ACCOUNT:secret:YOUR_SECRET_NAME*"
      ]
    }]
  })
}
```

### 4. Alternative Approach: Using Environment Variables via ECS

If you prefer not to modify your application code, you can have ECS inject the secret as an environment variable:

```hcl
container_definitions = jsonencode([{
  name      = "g4app"
  image     = "${aws_ecr_repository.g4app.repository_url}:latest"
  essential = true
  portMappings = [{
    containerPort = 3000
    hostPort      = 3000
  }]
  environment = [
    {
      name  = "NODE_ENV",
      value = "production"
    }
  ]
  secrets = [
    {
      name      = "MONGO_URI",
      valueFrom = "arn:aws:secretsmanager:us-east-1:YOUR_AWS_ACCOUNT:secret:YOUR_SECRET_NAME"
    }
  ]
}])
```

Then your existing code can continue using `process.env.MONGO_URI` as before.

### Important Notes:

1. Make sure to replace placeholders like `YOUR_SECRET_NAME`, `YOUR_AWS_ACCOUNT`, and region with your actual values.
2. The IAM roles need proper permissions to access Secrets Manager.
3. For local development, you might want to keep the .env option as a fallback.
4. Consider adding error handling for cases where the secret can't be retrieved.

Would you like me to provide more specific code for any particular part of your setup?