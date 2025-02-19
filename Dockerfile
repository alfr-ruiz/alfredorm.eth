FROM node:20-alpine

RUN apk add --no-cache bash curl python3 py3-pip && \
    curl -fSsL https://sdk.cloud.google.com | bash
ENV PATH $PATH:/root/google-cloud-sdk/bin

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm run build

RUN gcloud components install beta

RUN gcloud iam service-accounts get-iam-policy $SERVICE_ACCOUNT_EMAIL \
    --project=$PROJECT_ID \
    --format="TABLE(BINDINGS.ROLE)"

RUN gcloud projects add-iam-policy-binding $PROJECT_ID

# Check if current user has storage.admin role
RUN gcloud projects get-iam-policy personal-eth-site \
    --flatten="bindings[].members" \
    --format="table(bindings.role)" \
    --filter="bindings.members:user:\$(gcloud config get-value account)"

# Add Storage Admin role to your account
RUN gcloud projects add-iam-policy-binding personal-eth-site \
  --member="user:\$(gcloud config get-value account)" \
  --role="roles/storage.admin"

EXPOSE 3000

CMD ["npm", "start"]
