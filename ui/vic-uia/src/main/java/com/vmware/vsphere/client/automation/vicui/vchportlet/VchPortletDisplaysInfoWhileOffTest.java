package com.vmware.vsphere.client.automation.vicui.vchportlet;

import org.testng.annotations.Test;
import com.vmware.client.automation.common.spec.TaskSpec;
import com.vmware.client.automation.common.step.VerifyTaskByUiStep;
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
import com.vmware.vsphere.client.automation.vicui.common.step.InvokeVmPowerOperationUiStepConfirmYes;
import com.vmware.vsphere.client.automation.vicui.common.step.TurnOnVmByApiStep;
import com.vmware.vsphere.client.automation.vicui.vchportlet.step.VerifyVchDockerEndpointIsValidStep;
import com.vmware.vsphere.client.automation.vm.common.messages.VmTaskMessages;
import com.vmware.vsphere.client.automation.vm.lib.ops.model.VmOpsModel.VmPowerState;
import com.vmware.vsphere.client.automation.vm.lib.ops.spec.VmPowerStateSpec;
import com.vmware.vsphere.client.automation.vm.lib.ops.step.VerifyVmPowerStateViaApiStep;
import com.vmware.vsphere.client.test.i18n.I18n;

/**
 * Test class for VCH VM portlet in the NGC client.
 * Executes the following test work-flow:
 *  1. Open a browser
 *  2. Login as admin user
 *  3. Navigate to the VCH VM Summary tab
 *  4. Turn off VCH VM
 *  5. Verify Power Off VM task via UI
 *  5. Verify via API if VM is off
 *  6. Verify dockerApiEndpoint equals the placeholder value
 */ 

public class VchPortletDisplaysInfoWhileOffTest extends NGCTestWorkflow {
	
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
	    
	    // Spec for the VmPowerState
	    VmPowerStateSpec vmPowerStateSpec = new VmPowerStateSpec();
	    vmPowerStateSpec.vm.set(vmSpec);
	    vmPowerStateSpec.powerState.set(VmPowerState.POWER_OFF);
	    
	    // Spec for the power on VM task 
	    TaskSpec powerOffVmTaskSpec = new TaskSpec();
	    powerOffVmTaskSpec.name.set(I18n.get(VmTaskMessages.class).powerOff());
	    powerOffVmTaskSpec.status.set(TaskSpec.TaskStatus.COMPLETED);
	    powerOffVmTaskSpec.target.set(vmSpec);
	    
	    testSpec.add(requestedVcSpec, vmSpec, vmLocationSpec, vmPowerStateSpec, powerOffVmTaskSpec);
	    
	    super.initSpec(testSpec, testbedBridge);
	}
	
	@Override
	public void composePrereqSteps(WorkflowStepsSequence<TestWorkflowStepContext> flow) {
		super.composePrereqSteps(flow);
		
		flow.appendStep("Turn on VCH VM through the API", new TurnOnVmByApiStep());
	}
	
	@Override
	public void composeTestSteps(WorkflowStepsSequence<TestWorkflowStepContext> flow) {
		super.composeTestSteps(flow);
		
		flow.appendStep("Navigating to the VCH VM", new VmNavigationStep());
//		flow.appendStep("Clicking the Summary tab", new ClickSummaryTabStep());
		
		flow.appendStep("Power Off VM", new InvokeVmPowerOperationUiStepConfirmYes());
	    flow.appendStep("Verify Power Off VM task via UI", new VerifyTaskByUiStep());
	    flow.appendStep("Verify via API that the VM is powered off", new VerifyVmPowerStateViaApiStep());
//	    flow.appendStep("Verifying \"dockerApiEndpoint\" shows a valid value", new VerifyVchDockerEndpointIsValidStep());
	    
		// check if name is not "-"
		// turn off vch vm
		// verify via api if vm is off
		// check if name turns into "-"
	}
	
	@Override
	@Test(description = "Check if VCH portlet shows a placeholder value while the VM state is OFF")
	@TestID(id = "1")
	public void execute() throws Exception {
		super.execute();
	}
}
