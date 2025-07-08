import base64
import file

import models.com.example.platform.v1alpha1 as platformv1alpha1
import models.io.upbound.aws.v1beta1 as awsv1beta1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.k8s.apimachinery.pkg.apis.meta.v1 as k8s

aws_access_key_id = file.read_env("UP_AWS_ACCESS_KEY_ID")
aws_secret_access_key = file.read_env("UP_AWS_SECRET_ACCESS_KEY")
aws_session_token = file.read_env("UP_AWS_SESSION_TOKEN")


schema Secret:
    apiVersion: "v1" = "v1"
    kind: "Secret" = "Secret"
    metadata?: k8s.ObjectMeta
    type: "Opaque" = "Opaque"
    data?: {str:str}

_items = [
    metav1alpha1.E2ETest{
        metadata.name = "e2etest-xstoragebucket"
        spec = {
            crossplane.autoUpgrade.channel = "Rapid"
            defaultConditions = [
                "Ready"
            ]
            manifests = [
                platformv1alpha1.XStorageBucket{
                    metadata.name = "uptest-bucket-xr-kcl"
                    spec.parameters = {
                        acl = "private"
                        region = "eu-central-1"
                        versioning: True
                    }
                }
            ]
            extraResources = [
                awsv1beta1.ProviderConfig{
                    metadata.name = "default"
                    spec.credentials = {
                        source = "Secret"
                        secretRef = {
                            name = "aws-credentials"
                            namespace = "crossplane-system"
                            key = "credentials"
                        }
                    }
                },
                Secret{
                    metadata={
                        name="aws-credentials",
                        namespace="crossplane-system",
                    },
                    data={
                        "credentials": base64.encode("""[default]
aws_access_key_id = ${aws_access_key_id}
aws_secret_access_key = ${aws_secret_access_key}
aws_session_token = ${aws_session_token}
""")
                    }
                }
            ]
            skipDelete = False
            timeoutSeconds = 300 # 5 minutes
        }
    }
]
items = _items