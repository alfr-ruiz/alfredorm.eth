# Check if current user has storage.admin role
gcloud projects get-iam-policy personal-eth-site \
  --flatten="bindings[].members" \gcloud services enable \
    cloudbuild.googleapis.com \
    run.googleapis.com \
    containerregistry.googleapis.com
  --format="table(bindings.role)" \
  --filter="bindings.members:user:$(gcloud config get-value account)"# Add Storage Admin role to your account
  gcloud projects add-iam-policy-binding personal-eth-site \
    --member="user:$(gcloud config get-value account)" \
    --role="roles/storage.admin"FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

RUN npm run build

EXPOSE 3000

CMD ["npm", "start"]
