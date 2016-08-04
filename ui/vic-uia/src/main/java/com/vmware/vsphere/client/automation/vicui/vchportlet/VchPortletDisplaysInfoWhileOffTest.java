package com.vmware.vsphere.client.automation.vicui.vchportlet;

import org.testng.annotations.Test;
import com.vmware.client.automation.workflow.common.WorkflowSpec;
import com.vmware.client.automation.workflow.common.WorkflowStepsSequence;
import com.vmware.client.automation.workflow.explorer.TestBedBridge;
import com.vmware.client.automation.workflow.explorer.TestbedSpecConsumer;
import com.vmware.client.automation.workflow.test.TestWorkflowStepContext;
import com.vmware.vim.binding.vim.vm.ConfigSpec;
import com.vmware.vsphere.client.automation.common.workflow.NGCTestWorkflow;
import com.vmware.vsphere.client.automation.components.navigator.NGCNavigator;
import com.vmware.vsphere.client.automation.components.navigator.spec.VappLocationSpec;
import com.vmware.vsphere.client.automation.components.navigator.spec.VmLocationSpec;
import com.vmware.vsphere.client.automation.components.navigator.step.VappNavigationStep;
import com.vmware.vsphere.client.automation.components.navigator.step.VmNavigationStep;
import com.vmware.vsphere.client.automation.provider.commontb.CommonTestBedProvider;
import com.vmware.vsphere.client.automation.srv.common.spec.HostSpec;
import com.vmware.vsphere.client.automation.srv.common.spec.SpecFactory;
import com.vmware.vsphere.client.automation.srv.common.spec.VappSpec;
import com.vmware.vsphere.client.automation.srv.common.spec.VcSpec;
import com.vmware.vsphere.client.automation.srv.common.spec.VmSpec;
import com.vmware.vsphere.client.automation.vicui.common.VicUIConstants;
import com.vmware.vsphere.client.automation.vicui.common.step.ClickSummaryTabStep;
import com.vmware.vsphere.client.automation.vicui.common.step.EnsureVappIsOnStep;
import com.vmware.vsphere.client.automation.vicui.common.step.TurnOffVappByApiStep;
import com.vmware.vsphere.client.automation.vicui.vchportlet.step.VerifyVchDockerEndpointIsValidStep;
import com.vmware.vsphere.client.automation.vm.lib.ops.model.VmOpsModel.VmPowerState;
import com.vmware.vsphere.client.automation.vm.lib.ops.spec.VmPowerStateSpec;

/**
 * Test class for VCH VM portlet in the NGC client.
 * Executes the following test work-flow:
 *  1. Open a browser
 *  2. Login as admin user
 *  3. Navigate to the VCH vApp
 *  4. Turn off the vApp
 *  5. Navigate to the VCH VM Summary tab
 *  6. Verify if dockerApiEndpoint equals the placeholder value
 */ 

public class VchPortletDisplaysInfoWhileOffTest extends NGCTestWorkflow {
	
	@Override
	public void initSpec(WorkflowSpec testSpec, TestBedBridge testbedBridge) {
		TestbedSpecConsumer testBed = testbedBridge.requestTestbed(CommonTestBedProvider.class, true);
		
		// Spec for the VC
	    VcSpec requestedVcSpec = testBed.getPublishedEntitySpec(CommonTestBedProvider.VC_ENTITY);

	    // Spec for the host
	    HostSpec requestedHostSpec = testBed.getPublishedEntitySpec(CommonTestBedProvider.CLUSTER_HOST_ENTITY);
	    
	    // Spec for the vApp created by VIC
	    VappSpec vAppSpec = SpecFactory.getSpec(VappSpec.class, requestedHostSpec);
	    vAppSpec.name.set(VicUIConstants.VCH_VM_NAME);
	    
	    // VmSpec for VCH
	    VmSpec vmSpec = SpecFactory.getSpec(VmSpec.class, requestedHostSpec);	    
	    vmSpec.name.set(VicUIConstants.VCH_VM_NAME);
	    
	    // Spec for the location to the vApp and VM
	    VappLocationSpec vAppLocationSpec = new VappLocationSpec(vAppSpec);
	    VmLocationSpec vmLocationSpec = new VmLocationSpec(vmSpec, NGCNavigator.NID_ENTITY_PRIMARY_TAB_SUMMARY);
	    
	    // Spec for the VmPowerState
	    VmPowerStateSpec vmPowerStateSpec = new VmPowerStateSpec();
	    vmPowerStateSpec.vm.set(vmSpec);
	    vmPowerStateSpec.powerState.set(VmPowerState.POWER_OFF);
	    
	    testSpec.add(requestedVcSpec, vAppSpec, vmSpec, vAppLocationSpec, vmLocationSpec, vmPowerStateSpec);
	    
	    super.initSpec(testSpec, testbedBridge);
	}
	
	@Override
	public void composePrereqSteps(WorkflowStepsSequence<TestWorkflowStepContext> flow) {
		super.composePrereqSteps(flow);
		
		flow.appendStep("Ensure vApp is ON", new EnsureVappIsOnStep());
	}
	
	@Override
	public void composeTestSteps(WorkflowStepsSequence<TestWorkflowStepContext> flow) {
		super.composeTestSteps(flow);
		
		flow.appendStep("Navigating to the VIC vApp", new VappNavigationStep());
		flow.appendStep("Power Off vApp", new TurnOffVappByApiStep());
		flow.appendStep("Navigating to the VCH VM", new VmNavigationStep());
		if(VicUIConstants.VC_VERSION_USING.equals(VicUIConstants.VC_VERSION_6_0)) {
			flow.appendStep("Clicking the Summary tab", new ClickSummaryTabStep());
		}
	    flow.appendStep("Verifying \"dockerApiEndpoint\" shows a valid value", new VerifyVchDockerEndpointIsValidStep());
	}
	
	@Override
	@Test(description = "Test if VCH VM portlet shows a placeholder value while the VM state is OFF")
	@TestID(id = "2")
	public void execute() throws Exception {
		super.execute();
	}
}
