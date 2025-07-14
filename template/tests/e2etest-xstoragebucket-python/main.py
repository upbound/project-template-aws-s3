import base64
import os
from pydantic import BaseModel

from .model.io.upbound.dev.meta.e2etest import v1alpha1 as e2etest
from .model.io.k8s.apimachinery.pkg.apis.meta import v1 as k8s
from .model.com.example.platform.xstoragebucket import v1alpha1 as xstoragebucket
from .model.io.upbound.aws.providerconfig import v1beta1 as providerconfig

class Secret(BaseModel):
    apiVersion: str = "v1"
    kind: str = "Secret"
    metadata: k8s.ObjectMeta
    type: str = "Opaque"
    data: dict[str, str] = {}

bucket_manifest = xstoragebucket.XStorageBucket(
    metadata=k8s.ObjectMeta(
        name="uptest-bucket-xr-python",
    ),
    spec=xstoragebucket.Spec(
        parameters=xstoragebucket.Parameters(
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

provider_config = providerconfig.ProviderConfig(
    metadata=k8s.ObjectMeta(
        name="default",
    ),
    spec=providerconfig.Spec(
        credentials=providerconfig.Credentials(
            source="Secret",
            secretRef=providerconfig.SecretRef(
                name="aws-credentials",
                namespace="crossplane-system",
                key="credentials",
            ),
        ),
    ),
)

test = e2etest.E2ETest(
    metadata=k8s.ObjectMeta(
        name="e2etest-xstoragebucket",
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
        manifests=[bucket_manifest.model_dump()],
        extraResources=[provider_config.model_dump(), provider_creds.model_dump()],
        skipDelete=False,
        timeoutSeconds=300, # 5 minutes
    )
)
