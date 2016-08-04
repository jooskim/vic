package com.vmware.vsphere.client.automation.vicui.common;

import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Parameters;

import com.vmware.client.automation.workflow.common.WorkflowStepsSequence;
import com.vmware.client.automation.workflow.test.TestWorkflowStepContext;
import com.vmware.vsphere.client.automation.common.workflow.NGCTestWorkflow;
import com.vmware.vsphere.client.automation.srv.common.spec.UserSpec;
import com.vmware.vsphere.client.automation.srv.common.spec.VcSpec;

public class VicUITestWorkflow extends NGCTestWorkflow {
	/*
	 * This disables admin user creation and forces the framework to use the administrator@vsphere.local account because 6.0 has an issue with SSO 
	 */
	
	protected static String _containerVmName;
	protected static String _vchVmName;
	protected static boolean _isVcVersion6_0;
	
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
	
	@BeforeSuite
	@Parameters({"containerVmName", "vchVmName", "vcVersion"})
	public void loadVmNames(String containerVmName, String vchVmName, String vcVersion) {
		System.out.println("Loading VM names " + containerVmName + ", " + vchVmName);
		System.out.println("VC version: " + vcVersion);
		_containerVmName = containerVmName;
		_vchVmName = vchVmName;
		_isVcVersion6_0 = vcVersion.equals(VicUIConstants.VC_VERSION_6_0);
	}
}
