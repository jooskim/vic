package com.vmware.vsphere.client.automation.vicui.common;

import com.vmware.client.automation.workflow.common.WorkflowStepsSequence;
import com.vmware.client.automation.workflow.test.TestWorkflowStepContext;
import com.vmware.vsphere.client.automation.common.workflow.NGCTestWorkflow;
import com.vmware.vsphere.client.automation.srv.common.spec.UserSpec;
import com.vmware.vsphere.client.automation.srv.common.spec.VcSpec;

public class VicUITestWorkflow extends NGCTestWorkflow {
	/*
	 * This disables admin user creation and forces the framework to use the administrator@vsphere.local account because 6.0 has an issue with SSO 
	 */
	
	@Override
	protected UserSpec generateUserSpec(VcSpec vcSpec) {
		UserSpec userSpec = new UserSpec();
		userSpec.username.set("administrator@vsphere.local");
		userSpec.password.set("Admin!23");
		userSpec.parent.set(vcSpec);
		userSpec.tag.set(NGCTestWorkflow.TEST_USER_SPEC_TAG);
		
		return userSpec;
	}
	
	@Override
	public void composePrereqSteps(WorkflowStepsSequence<TestWorkflowStepContext> flow) {
		
	}
}
