package test

import (
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.ibm.com/mathewss/tf-helper/modules/terratest"
	"os"
	"testing"
)

func TestCode(t *testing.T) {
	options := &terraform.Options{
		TerraformDir: "../terraform",

		// Variables used in module
		Vars: map[string]interface{}{
			"ibmcloud_api_key":    os.Getenv("API_KEY"),
			"sap_master_password": os.Getenv("SAP_PASS"),
			"VPC":                 os.Getenv("VPC"),
			"SECURITYGROUP":       os.Getenv("SECURITYGROUP"),
			"SUBNET":              os.Getenv("SUBNET"),
		},
	}
	terratest.RunTestCase(t, &CodeTest{options}, options)
}
