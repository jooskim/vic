package com.vmware.vsphere.client.automation.vicui.vchportletexists;

import org.testng.annotations.Test;
import com.vmware.client.automation.common.spec.TaskSpec;
import com.vmware.client.automation.common.step.VerifyEntityNameByUiStep;
import com.vmware.client.automation.common.step.VerifyTaskByUiStep;
import com.vmware.client.automation.workflow.BaseTest.TestID;
import com.vmware.client.automation.workflow.common.WorkflowSpec;
import com.vmware.client.automation.workflow.common.WorkflowStepsSequence;
import com.vmware.client.automation.workflow.explorer.TestBedBridge;
import com.vmware.client.automation.workflow.explorer.TestbedSpecConsumer;
import com.vmware.client.automation.workflow.test.TestWorkflowStepContext;
import com.vmware.vsphere.client.automation.common.step.ClickNextWizardButtonStep;
import com.vmware.vsphere.client.automation.common.workflow.NGCTestWorkflow;
import com.vmware.vsphere.client.automation.components.navigator.NGCNavigator;
import com.vmware.vsphere.client.automation.components.navigator.spec.ClusterLocationSpec;
import com.vmware.vsphere.client.automation.components.navigator.spec.VmLocationSpec;
import com.vmware.vsphere.client.automation.components.navigator.step.ClusterNavigationStep;
import com.vmware.vsphere.client.automation.components.navigator.step.HostNavigationStep;
import com.vmware.vsphere.client.automation.components.navigator.step.VmNavigationStep;
import com.vmware.vsphere.client.automation.provider.commontb.CommonTestBedProvider;
import com.vmware.vsphere.client.automation.srv.common.spec.ClusterSpec;
import com.vmware.vsphere.client.automation.srv.common.spec.DatacenterSpec;
import com.vmware.vsphere.client.automation.srv.common.spec.DatastoreSpec;
import com.vmware.vsphere.client.automation.srv.common.spec.HostSpec;
import com.vmware.vsphere.client.automation.srv.common.spec.SpecFactory;
import com.vmware.vsphere.client.automation.srv.common.spec.VcSpec;
import com.vmware.vsphere.client.automation.srv.common.spec.VmSpec;
import com.vmware.vsphere.client.automation.srv.common.step.VerifyVmExistenceByApiStep;
import com.vmware.vsphere.client.automation.vm.common.VmUtil;
import com.vmware.vsphere.client.automation.vm.lib.createvm.spec.CreateVmSpec;
import com.vmware.vsphere.client.automation.vm.lib.createvm.spec.CreateVmSpec.VmCreationType;

/**
 * import vicui-specific spec, steps here
*/

/**
 * Test class for create VM in the NGC client.
 * Executes the following test work-flow:
 *  1. Open a browser
 *  2. Login as admin user
 *  3. Navigate to the cluster
 *  4. -
 */ 

public class VchPortletExistsTest extends NGCTestWorkflow {
	protected static final String TAG_SUMMARY_TAB = "TAG_SUMMARY_TAB";
	
	@Override
	public void initSpec(WorkflowSpec testSpec, TestBedBridge testbedBridge) {
		TestbedSpecConsumer testBed = testbedBridge.requestTestbed(CommonTestBedProvider.class, true);
		
		// Spec for the VC
	    VcSpec requestedVcSpec = testBed.getPublishedEntitySpec(CommonTestBedProvider.VC_ENTITY);

	    // Spec for the datacenter
	    DatacenterSpec requestedDatacenterSpec = testBed.getPublishedEntitySpec(CommonTestBedProvider.DC_ENTITY);

	    // Spec for the cluster
	    ClusterSpec requestedClusterSpec = testBed.getPublishedEntitySpec(CommonTestBedProvider.CLUSTER_ENTITY);
	    
	    // Spec for the host
	    HostSpec requestedHostSpec = testBed.getPublishedEntitySpec(CommonTestBedProvider.CLUSTER_HOST_ENTITY);
	    
	    //
	    VmSpec vmSpec = SpecFactory.getSpec(VmSpec.class, requestedHostSpec);
	    vmSpec.name.set("virtual-container-host");
	    
//	    // Spec for the location to the Cluster
//	    ClusterLocationSpec clusterLocationSpec = new ClusterLocationSpec(requestedClusterSpec);
//	    ClusterLocationSpec clusterSummaryLocationSpec = new ClusterLocationSpec(requestedClusterSpec, NGCNavigator.NID_ENTITY_PRIMARY_TAB_SUMMARY);
//	    clusterSummaryLocationSpec.tag.set(TAG_SUMMARY_TAB);

	    // Spec for the location to the VM
	    VmLocationSpec vmLocationSpec = new VmLocationSpec(vmSpec, NGCNavigator.NID_ENTITY_PRIMARY_TAB_SUMMARY);
	    vmLocationSpec.tag.set(TAG_SUMMARY_TAB);
	    
	    testSpec.add(requestedVcSpec, requestedDatacenterSpec, requestedClusterSpec, vmLocationSpec);
	    super.initSpec(testSpec, testbedBridge);
	}
	
	@Override
	public void composeTestSteps(WorkflowStepsSequence<TestWorkflowStepContext> flow) {
		super.composeTestSteps(flow);
		
		flow.appendStep("Navigating to the VCH VM", new VmNavigationStep(), new String[] { TAG_SUMMARY_TAB });
	}
	
	@Override
	@Test(description = "Check if VCH portlet is visible")
	@TestID(id = "1")
	public void execute() throws Exception {
		super.execute();
	}
}
