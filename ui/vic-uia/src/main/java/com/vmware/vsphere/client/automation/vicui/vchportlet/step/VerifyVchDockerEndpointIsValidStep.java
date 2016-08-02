package com.vmware.vsphere.client.automation.vicui.vchportlet.step;

import com.vmware.client.automation.workflow.CommonUIWorkflowStep;
import com.vmware.suitaf.apl.IDGroup;
import com.vmware.suitaf.apl.Property;
import com.vmware.vsphere.client.automation.vm.lib.ops.model.VmOpsModel.VmPowerState;
import com.vmware.vsphere.client.automation.vm.lib.ops.spec.VmPowerStateSpec;

public class VerifyVchDockerEndpointIsValidStep extends CommonUIWorkflowStep {
	
	private VmPowerStateSpec _vmPowerStateSpec;
	private static final IDGroup VM_SUMMARY_VCHPORTLET_DOCKERAPIENDPOINT = IDGroup.toIDGroup("dockerApiEndpoint");
	private static final String DOCKER_API_ENDPOINT_PLACEHOLDER_VALUE = "-";
	
	@Override
	public void execute() throws Exception {
		if(_vmPowerStateSpec.powerState.get() == VmPowerState.POWER_ON) { 
			verifyFatal(!UI.component.property.get(Property.TEXT, VM_SUMMARY_VCHPORTLET_DOCKERAPIENDPOINT).equalsIgnoreCase(DOCKER_API_ENDPOINT_PLACEHOLDER_VALUE), "Verifying \"dockerApiEndpoint\" is not \"-\"");
			
		} else {
			verifyFatal(UI.component.property.get(Property.TEXT, VM_SUMMARY_VCHPORTLET_DOCKERAPIENDPOINT).equalsIgnoreCase(DOCKER_API_ENDPOINT_PLACEHOLDER_VALUE), "Verifying \"dockerApiEndpoint\" is \"-\"");
		}
	}
	
	@Override
	public void prepare() {
		_vmPowerStateSpec = getSpec().links.get(VmPowerStateSpec.class);
		
		if(_vmPowerStateSpec == null) {
			throw new IllegalArgumentException("VmPowerStateSpec not found");
		}
	}

}
