// Package main generates a CompositionTest.
//
// This test suite validates the creation of resources for the XStorageBucket
// XR.
//
// Creation of resources happens in two sequential calls to the composition
// function:
//
//  1. The first time the function is called, the bucket has not yet been
//     created. Other resources depend on the bucket's name, so the function
//     creates only the bucket.
//
//  2. When the function is called again after the bucket has been created, its
//     name is available, so the rest of the resources can be created.
//
// The test suite contains two tests, one for each of the sequential calls. The
// second test includes the bucket in its observed resources, triggering
// creation of the dependent resources.
package main

import (
	"encoding/json"
	"fmt"
	"os"

	"dev.upbound.io/models/com/example/platform/v1alpha1"
	metav1 "dev.upbound.io/models/io/k8s/meta/v1"
	s3v1beta1 "dev.upbound.io/models/io/upbound/aws/s3/v1beta1"
	metav1alpha1 "dev.upbound.io/models/io/upbound/dev/meta/v1alpha1"
	"k8s.io/utils/ptr"
	"sigs.k8s.io/yaml"
)

type compositionTestList struct {
	Items []metav1alpha1.CompositionTest `json:"items"`
}

func main() {
	// The XR we expect after the composition function runs. It matches the XR
	// defined in examples/xstoragebuckets/example.yaml.
	expectedXR := &v1alpha1.XStorageBucket{
		APIVersion: ptr.To(v1alpha1.XStorageBucketAPIVersionplatformExampleComV1Alpha1),
		Kind:       ptr.To(v1alpha1.XStorageBucketKindXStorageBucket),
		Metadata: &metav1.ObjectMeta{
			Name: ptr.To("example"),
		},
		Spec: &v1alpha1.XStorageBucketSpec{
			Parameters: &v1alpha1.XStorageBucketSpecParameters{
				ACL:        ptr.To(v1alpha1.XStorageBucketSpecParametersACLprivate),
				Region:     ptr.To("us-west-1"),
				Versioning: ptr.To(true),
			},
		},
	}

	// On the first call the function creates only the bucket, since the other
	// resources depend on the bucket's external name.
	expectedBucketBefore := &s3v1beta1.Bucket{
		APIVersion: ptr.To(s3v1beta1.BucketAPIVersions3AwsUpboundIoV1Beta1),
		Kind:       ptr.To(s3v1beta1.BucketKindBucket),
		Metadata: &metav1.ObjectMeta{
			Annotations: &map[string]string{
				"crossplane.io/composition-resource-name": "bucket",
			},
		},
		Spec: &s3v1beta1.BucketSpec{
			ForProvider: &s3v1beta1.BucketSpecForProvider{
				Region: ptr.To("us-west-1"),
			},
		},
	}

	// The bucket as observed by Crossplane after creation. Its external-name
	// annotation is what lets the function create the dependent resources.
	observedBucket := &s3v1beta1.Bucket{
		APIVersion: ptr.To(s3v1beta1.BucketAPIVersions3AwsUpboundIoV1Beta1),
		Kind:       ptr.To(s3v1beta1.BucketKindBucket),
		Metadata: &metav1.ObjectMeta{
			Name: ptr.To("example-bucket"),
			Annotations: &map[string]string{
				"crossplane.io/composition-resource-name": "bucket",
				"crossplane.io/external-name":             "example-bucket",
			},
		},
		Spec: &s3v1beta1.BucketSpec{
			ForProvider: &s3v1beta1.BucketSpecForProvider{
				Region: ptr.To("us-west-1"),
			},
		},
	}

	expectedBucketAfter := &s3v1beta1.Bucket{
		APIVersion: ptr.To(s3v1beta1.BucketAPIVersions3AwsUpboundIoV1Beta1),
		Kind:       ptr.To(s3v1beta1.BucketKindBucket),
		Metadata: &metav1.ObjectMeta{
			Name: ptr.To("example-bucket"),
			Annotations: &map[string]string{
				"crossplane.io/composition-resource-name": "bucket",
			},
		},
		Spec: &s3v1beta1.BucketSpec{
			ForProvider: &s3v1beta1.BucketSpecForProvider{
				Region: ptr.To("us-west-1"),
			},
		},
	}

	expectedPAB := &s3v1beta1.BucketPublicAccessBlock{
		APIVersion: ptr.To(s3v1beta1.BucketPublicAccessBlockAPIVersions3AwsUpboundIoV1Beta1),
		Kind:       ptr.To(s3v1beta1.BucketPublicAccessBlockKindBucketPublicAccessBlock),
		Metadata: &metav1.ObjectMeta{
			Annotations: &map[string]string{
				"crossplane.io/composition-resource-name": "pab",
			},
		},
		Spec: &s3v1beta1.BucketPublicAccessBlockSpec{
			ForProvider: &s3v1beta1.BucketPublicAccessBlockSpecForProvider{
				Bucket:                ptr.To("example-bucket"),
				Region:                ptr.To("us-west-1"),
				BlockPublicAcls:       ptr.To(true),
				IgnorePublicAcls:      ptr.To(true),
				BlockPublicPolicy:     ptr.To(true),
				RestrictPublicBuckets: ptr.To(true),
			},
		},
	}

	expectedSSE := &s3v1beta1.BucketServerSideEncryptionConfiguration{
		APIVersion: ptr.To(s3v1beta1.BucketServerSideEncryptionConfigurationAPIVersions3AwsUpboundIoV1Beta1),
		Kind:       ptr.To(s3v1beta1.BucketServerSideEncryptionConfigurationKindBucketServerSideEncryptionConfiguration),
		Metadata: &metav1.ObjectMeta{
			Annotations: &map[string]string{
				"crossplane.io/composition-resource-name": "sse",
			},
		},
		Spec: &s3v1beta1.BucketServerSideEncryptionConfigurationSpec{
			ForProvider: &s3v1beta1.BucketServerSideEncryptionConfigurationSpecForProvider{
				Bucket: ptr.To("example-bucket"),
				Region: ptr.To("us-west-1"),
				Rule: &[]s3v1beta1.BucketServerSideEncryptionConfigurationSpecForProviderRuleItem{{
					ApplyServerSideEncryptionByDefault: &[]s3v1beta1.BucketServerSideEncryptionConfigurationSpecForProviderRuleItemApplyServerSideEncryptionByDefaultItem{{
						SseAlgorithm: ptr.To("AES256"),
					}},
					BucketKeyEnabled: ptr.To(true),
				}},
			},
		},
	}

	expectedVersioning := &s3v1beta1.BucketVersioning{
		APIVersion: ptr.To(s3v1beta1.BucketVersioningAPIVersions3AwsUpboundIoV1Beta1),
		Kind:       ptr.To(s3v1beta1.BucketVersioningKindBucketVersioning),
		Metadata: &metav1.ObjectMeta{
			Annotations: &map[string]string{
				"crossplane.io/composition-resource-name": "versioning",
			},
		},
		Spec: &s3v1beta1.BucketVersioningSpec{
			ForProvider: &s3v1beta1.BucketVersioningSpecForProvider{
				Bucket: ptr.To("example-bucket"),
				Region: ptr.To("us-west-1"),
				VersioningConfiguration: &[]s3v1beta1.BucketVersioningSpecForProviderVersioningConfigurationItem{{
					Status: ptr.To("Enabled"),
				}},
			},
		},
	}

	tests := []metav1alpha1.CompositionTest{
		buildTest(
			"test-xstoragebucket-bucket-not-yet-created",
			nil,
			[]any{
				expectedXR,
				expectedBucketBefore,
			},
		),
		buildTest(
			"test-xstoragebucket-bucket-created",
			[]any{
				observedBucket,
			},
			[]any{
				expectedXR,
				expectedBucketAfter,
				expectedPAB,
				expectedSSE,
				expectedVersioning,
			},
		),
	}

	// Wrap in items array as expected by the test runner.
	output := compositionTestList{Items: tests}
	out, err := yaml.Marshal(output)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error encoding YAML: %v\n", err)
		os.Exit(1)
	}
	fmt.Print(string(out))
}

func buildTest(name string, observed, expected []any) metav1alpha1.CompositionTest {
	assertResources := resourcesToItems[metav1alpha1.CompositionTestSpecAssertResourcesItem](expected...)
	spec := &metav1alpha1.CompositionTestSpec{
		AssertResources: &assertResources,
		CompositionPath: ptr.To("apis/xstoragebucket/composition.yaml"),
		XrPath:          ptr.To("examples/xstoragebuckets/example.yaml"),
		XrdPath:         ptr.To("apis/xstoragebucket/definition.yaml"),
		TimeoutSeconds:  ptr.To(120),
		Validate:        ptr.To(false),
	}
	if len(observed) > 0 {
		observedResources := resourcesToItems[metav1alpha1.CompositionTestSpecObservedResourcesItem](observed...)
		spec.ObservedResources = &observedResources
	}
	return metav1alpha1.CompositionTest{
		APIVersion: ptr.To(metav1alpha1.CompositionTestAPIVersionmetaDevUpboundIoV1Alpha1),
		Kind:       ptr.To(metav1alpha1.CompositionTestKindCompositionTest),
		Metadata: &metav1.ObjectMeta{
			Name: ptr.To(name),
		},
		Spec: spec,
	}
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
