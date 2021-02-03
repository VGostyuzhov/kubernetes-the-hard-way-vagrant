#!/bin/bash

ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

# Create the `encryption-config.yaml` encryption config file:

cat > ../configs/encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF
