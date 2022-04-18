#!/bin/sh

## generate typescript interface
npx -y swagger-typescript-api -p $SWAGGER_API_URL -o $BUILD_DIR -n api.ts