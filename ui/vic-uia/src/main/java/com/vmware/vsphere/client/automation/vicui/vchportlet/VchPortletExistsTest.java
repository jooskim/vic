package com.vmware.vsphere.client.automation.vicui.vchportlet;

import org.testng.annotations.Test;
import com.vmware.client.automation.workflow.common.WorkflowSpec;
import com.vmware.client.automation.workflow.common.WorkflowStepsSequence;
import com.vmware.client.automation.workflow.explorer.TestBedBridge;
import com.vmware.client.automation.workflow.explorer.TestbedSpecConsumer;
import com.vmware.client.automation.workflow.test.TestWorkflowStepContext;
import com.vmware.vsphere.client.automation.common.workflow.NGCTestWorkflow;
import com.vmware.vsphere.client.automation.components.navigator.NGCNavigator;
import com.vmware.vsphere.client.automation.components.navigator.spec.VmLocationSpec;
import com.vmware.vsphere.client.automation.components.navigator.step.VmNavigationStep;
import com.vmware.vsphere.client.automation.provider.commontb.CommonTestBedProvider;
import com.vmware.vsphere.client.automation.srv.common.spec.HostSpec;
import com.vmware.vsphere.client.automation.srv.common.spec.SpecFactory;
import com.vmware.vsphere.client.automation.srv.common.spec.VcSpec;
import com.vmware.vsphere.client.automation.srv.common.spec.VmSpec;
import com.vmware.vsphere.client.automation.vicui.common.VicUIConstants;
import com.vmware.vsphere.client.automation.vicui.common.step.ClickSummaryTabStep;
import com.vmware.vsphere.client.automation.vicui.vchportlet.step.VerifyVchPortletAttributeStep;

/**
 * Test class for VCH VM portlet in the NGC client.
 * Executes the following test work-flow:
 *  1. Open a browser
 *  2. Login as admin user
 *  3. Navigate to the VCH VM Summary tab
 *  4. Verify if property id "dockerApiEndpoint" exists
 */ 

public class VchPortletExistsTest extends NGCTestWorkflow {
	
	@Override
	public void initSpec(WorkflowSpec testSpec, TestBedBridge testbedBridge) {
		TestbedSpecConsumer testBed = testbedBridge.requestTestbed(CommonTestBedProvider.class, true);
		
		// Spec for the VC
	    VcSpec requestedVcSpec = testBed.getPublishedEntitySpec(CommonTestBedProvider.VC_ENTITY);

	    // Spec for the host
	    HostSpec requestedHostSpec = testBed.getPublishedEntitySpec(CommonTestBedProvider.CLUSTER_HOST_ENTITY);
	    
	    // VmSpec for VCH
	    VmSpec vmSpec = SpecFactory.getSpec(VmSpec.class, requestedHostSpec);
	    vmSpec.name.set(VicUIConstants.VCH_VM_NAME);
	    
	    // Spec for the location to the VM
	    VmLocationSpec vmLocationSpec = new VmLocationSpec(vmSpec, NGCNavigator.NID_ENTITY_PRIMARY_TAB_SUMMARY);
	    
	    testSpec.add(requestedVcSpec, vmSpec, vmLocationSpec);
	    
	    super.initSpec(testSpec, testbedBridge);
	}
	
	@Override
	public void composeTestSteps(WorkflowStepsSequence<TestWorkflowStepContext> flow) {
		super.composeTestSteps(flow);
		
		flow.appendStep("Navigating to the VCH VM", new VmNavigationStep());
		if(VicUIConstants.VC_VERSION_USING.equals(VicUIConstants.VC_VERSION_6_0)) {
			flow.appendStep("Clicking the Summary tab", new ClickSummaryTabStep());
		}
	    flow.appendStep("Verifying a VCH portlet property \"dockerApiEndpoint\" exists", new VerifyVchPortletAttributeStep());
	}
	
	@Override
	@Test(description = "Test if VCH VM portlet exists")
	@TestID(id = "1")
	public void execute() throws Exception {
		super.execute();
	}
}
