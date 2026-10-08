import base64
import os

import yaml
from pydantic import BaseModel
from models.io.upbound.dev.meta.e2etest import v1alpha1 as e2etest
from models.io.k8s.apimachinery.pkg.apis.meta import v1 as k8s
from models.com.example.platform.storagebucket import v1alpha1 as storagebucket
from models.io.upbound.m.aws.clusterproviderconfig import v1beta1 as clusterproviderconfig

class Secret(BaseModel):
    apiVersion: str = "v1"
    kind: str = "Secret"
    metadata: k8s.ObjectMeta
    type: str = "Opaque"
    data: dict[str, str] = {}

bucket_manifest = storagebucket.StorageBucket(
    metadata=k8s.ObjectMeta(
        name="uptest-bucket-xr-python",
        namespace="default",
    ),
    spec=storagebucket.Spec(
        parameters=storagebucket.Parameters(
            acl="private",
            region="eu-central-1",
            versioning=True,
        ),
    ),
)

provider_creds = Secret(
    metadata=k8s.ObjectMeta(
        name="aws-credentials",
        namespace="crossplane-system",
    ),
    data={
        "credentials": base64.b64encode(f'''[default]
aws_access_key_id = {os.environ.get("UP_AWS_ACCESS_KEY_ID", "")}
aws_secret_access_key = {os.environ.get("UP_AWS_SECRET_ACCESS_KEY", "")}
aws_session_token = {os.environ.get("UP_AWS_SESSION_TOKEN", "")}
'''.encode()).decode('ascii')
    }
)

# Namespaced managed resources use the ClusterProviderConfig named "default"
# unless they set a providerConfigRef.
provider_config = clusterproviderconfig.ClusterProviderConfig(
    metadata=k8s.ObjectMeta(
        name="default",
    ),
    spec=clusterproviderconfig.Spec(
        credentials=clusterproviderconfig.Credentials(
            source="Secret",
            secretRef=clusterproviderconfig.SecretRef(
                name="aws-credentials",
                namespace="crossplane-system",
                key="credentials",
            ),
        ),
    ),
)

test = e2etest.E2ETest(
    metadata=k8s.ObjectMeta(
        name="e2etest-storagebucket",
    ),
    spec=e2etest.Spec(
        crossplane=e2etest.Crossplane(
            autoUpgrade=e2etest.AutoUpgrade(
                channel="Rapid",
            ),
        ),
        defaultConditions=[
            "Ready",
        ],
        manifests=[bucket_manifest.model_dump(by_alias=True, exclude_none=True)],
        extraResources=[
            provider_config.model_dump(by_alias=True, exclude_none=True),
            provider_creds.model_dump(by_alias=True, exclude_none=True),
        ],
        skipDelete=False,
        timeoutSeconds=300, # 5 minutes
    )
)

# The test runner expects an "items" array, one entry per test.
output = {"items": [test.model_dump(by_alias=True, exclude_none=True)]}
print(yaml.dump(output))
