# pipeline-website

This module is response for building the public website and publishing a distributable artifact to the shared services S3 artifact bucket.

# Docker Image

The pipeline-website module uses the default codebuild image.

# Deployment

Each environment has it's own deployment pipeline. See the `service-website` module inside the account/environment you wish to target.
