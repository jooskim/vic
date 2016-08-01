package com.vmware.vsphere.client.automation.vicui.pluginstalled;

import org.testng.annotations.Test;

import com.vmware.vsphere.client.automation.common.workflow.NGCTestWorkflow;
import com.vmware.client.automation.workflow.common.WorkflowSpec;
import com.vmware.client.automation.workflow.common.WorkflowStepsSequence;
import com.vmware.client.automation.workflow.explorer.TestBedBridge;
import com.vmware.client.automation.workflow.explorer.TestbedSpecConsumer;
import com.vmware.client.automation.workflow.test.TestWorkflowStepContext;
import com.vmware.vsphere.client.automation.provider.commontb.CommonTestBedProvider;
import com.vmware.vsphere.client.automation.srv.common.spec.VcSpec;
import com.vmware.vsphere.client.automation.vicui.plugininstalled.spec.AdminNavigationSpec;
import com.vmware.vsphere.client.automation.vicui.plugininstalled.step.AdminNavigationStep;
import com.vmware.vsphere.client.automation.vicui.plugininstalled.step.FindVicUIStep;

public class PluginInstalledTest extends NGCTestWorkflow {
	@Override
	public void initSpec(WorkflowSpec testSpec, TestBedBridge testbedBridge) {
		TestbedSpecConsumer testBed = testbedBridge.requestTestbed(CommonTestBedProvider.class, true);
		VcSpec requestedVcSpec = testBed.getPublishedEntitySpec(CommonTestBedProvider.VC_ENTITY);
		AdminNavigationSpec adminNavigationSpec = new AdminNavigationSpec();
		
		testSpec.add(requestedVcSpec, adminNavigationSpec);
		
		super.initSpec(testSpec, testbedBridge);
	}

	@Override
	public void composeTestSteps(WorkflowStepsSequence<TestWorkflowStepContext> flow) {
		super.composeTestSteps(flow);
		
		flow.appendStep("navigating to the administration menu", new AdminNavigationStep());
		flow.appendStep("clicking a plugin item \"VicUI\"", new FindVicUIStep());
	}
	
	@Override
	@Test
	@TestID(id = "0")
	public void execute() throws Exception {
		super.execute();
	}
}
