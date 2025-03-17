import models.com.example.platform.v1alpha1 as platformv1alpha1
import models.io.upbound.aws.v1beta1 as awsv1beta1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

_items = [
    metav1alpha1.E2ETest{
        metadata.name = "e2etest-xstoragebucket-kcl"
        spec = {
            crossplane = {
                version="1.18.3-up.1"
                autoUpgrade = {
                    channel= "None"
                }
            }
            defaultConditions = [
                "Ready"
            ]
            manifests = [
                platformv1alpha1.XStorageBucket{
                    metadata.name = "uptest-bucket-xr"
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
                        source = "Upbound"
                        upbound.webIdentity = {
                            roleARN = "arn:aws:iam::609897127049:role/example-project-aws-uptest"
                        }
                    }
                }
            ]
            skipDelete = False
            timeoutSeconds = 4500
        }
    }
]
items = _items