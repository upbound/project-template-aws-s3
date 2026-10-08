// Package main generates an E2ETest.
package main

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"os"

	"dev.upbound.io/models/com/example/platform/v1alpha1"
	metav1 "dev.upbound.io/models/io/k8s/meta/v1"
	metav1alpha1 "dev.upbound.io/models/io/upbound/dev/meta/v1alpha1"
	awsmv1beta1 "dev.upbound.io/models/io/upbound/m/aws/v1beta1"
	"k8s.io/utils/ptr"
	"sigs.k8s.io/yaml"
)

// secret is a minimal representation of a core/v1 Secret. We define it here to
// avoid pulling in the full Kubernetes core as an API dependency.
type secret struct {
	APIVersion string             `json:"apiVersion"`
	Kind       string             `json:"kind"`
	Metadata   *metav1.ObjectMeta `json:"metadata,omitempty"`
	Type       string             `json:"type"`
	Data       map[string]string  `json:"data,omitempty"`
}

func main() {
	// Build the AWS credentials file from the environment and base64 encode it
	// for the Secret's data field.
	creds := fmt.Sprintf(`[default]
aws_access_key_id = %s
aws_secret_access_key = %s
aws_session_token = %s
`,
		os.Getenv("UP_AWS_ACCESS_KEY_ID"),
		os.Getenv("UP_AWS_SECRET_ACCESS_KEY"),
		os.Getenv("UP_AWS_SESSION_TOKEN"),
	)
	encodedCreds := base64.StdEncoding.EncodeToString([]byte(creds))

	// The StorageBucket XR to deploy for E2E testing.
	manifests := resourcesToItems[metav1alpha1.E2ETestSpecManifestsItem](
		&v1alpha1.StorageBucket{
			APIVersion: ptr.To(v1alpha1.StorageBucketAPIVersionplatformExampleComV1Alpha1),
			Kind:       ptr.To(v1alpha1.StorageBucketKindStorageBucket),
			Metadata: &metav1.ObjectMeta{
				Name:      ptr.To("uptest-bucket-xr-go"),
				Namespace: ptr.To("default"),
			},
			Spec: &v1alpha1.StorageBucketSpec{
				Parameters: &v1alpha1.StorageBucketSpecParameters{
					ACL:        ptr.To(v1alpha1.StorageBucketSpecParametersACLprivate),
					Region:     ptr.To("eu-central-1"),
					Versioning: ptr.To(true),
				},
			},
		},
	)

	// Extra resources: the AWS ClusterProviderConfig and the credentials Secret
	// it references. Namespaced managed resources use the ClusterProviderConfig
	// named "default" unless they set a providerConfigRef.
	extraResources := resourcesToItems[metav1alpha1.E2ETestSpecExtraResourcesItem](
		&awsmv1beta1.ClusterProviderConfig{
			APIVersion: ptr.To(awsmv1beta1.ClusterProviderConfigAPIVersionawsMUpboundIoV1Beta1),
			Kind:       ptr.To(awsmv1beta1.ClusterProviderConfigKindClusterProviderConfig),
			Metadata: &metav1.ObjectMeta{
				Name: ptr.To("default"),
			},
			Spec: &awsmv1beta1.ClusterProviderConfigSpec{
				Credentials: &awsmv1beta1.ClusterProviderConfigSpecCredentials{
					Source: ptr.To(awsmv1beta1.ClusterProviderConfigSpecCredentialsSourceSecret),
					SecretRef: &awsmv1beta1.ClusterProviderConfigSpecCredentialsSecretRef{
						Name:      ptr.To("aws-credentials"),
						Namespace: ptr.To("crossplane-system"),
						Key:       ptr.To("credentials"),
					},
				},
			},
		},
		&secret{
			APIVersion: "v1",
			Kind:       "Secret",
			Metadata: &metav1.ObjectMeta{
				Name:      ptr.To("aws-credentials"),
				Namespace: ptr.To("crossplane-system"),
			},
			Type: "Opaque",
			Data: map[string]string{
				"credentials": encodedCreds,
			},
		},
	)

	test := metav1alpha1.E2ETest{
		APIVersion: ptr.To(metav1alpha1.E2ETestAPIVersionmetaDevUpboundIoV1Alpha1),
		Kind:       ptr.To(metav1alpha1.E2ETestKindE2ETest),
		Metadata: &metav1.ObjectMeta{
			Name: ptr.To("e2etest-storagebucket"),
		},
		Spec: &metav1alpha1.E2ETestSpec{
			Crossplane: &metav1alpha1.E2ETestSpecCrossplane{
				AutoUpgrade: &metav1alpha1.E2ETestSpecCrossplaneAutoUpgrade{
					Channel: ptr.To(metav1alpha1.E2ETestSpecCrossplaneAutoUpgradeChannelRapid),
				},
			},
			DefaultConditions: &[]string{"Ready"},
			Manifests:         &manifests,
			ExtraResources:    &extraResources,
			SkipDelete:        ptr.To(false),
			TimeoutSeconds:    ptr.To(300), // 5 minutes
		},
	}

	// Wrap in items array as expected by the test runner.
	output := struct {
		Items []metav1alpha1.E2ETest `json:"items"`
	}{
		Items: []metav1alpha1.E2ETest{test},
	}
	out, err := yaml.Marshal(output)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error encoding YAML: %v\n", err)
		os.Exit(1)
	}
	fmt.Print(string(out))
}

func toItem[T any](resource any) T {
	var item T
	if err := convertViaJSON(&item, resource); err != nil {
		panic(fmt.Sprintf("converting item: %v", err))
	}
	return item
}

func resourcesToItems[T any](resources ...any) []T {
	items := make([]T, 0, len(resources))
	for _, res := range resources {
		items = append(items, toItem[T](res))
	}
	return items
}

func convertViaJSON(to, from any) error {
	bs, err := json.Marshal(from)
	if err != nil {
		return err
	}
	return json.Unmarshal(bs, to)
}
