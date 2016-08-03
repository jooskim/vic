package com.vmware.vsphere.client.automation.vicui.common.step;

import static com.vmware.client.automation.common.TestSpecValidator.ensureNotNull;

import com.vmware.client.automation.workflow.BaseWorkflowStep;
import com.vmware.client.automation.workflow.common.WorkflowSpec;
import com.vmware.vsphere.client.automation.srv.common.spec.VappSpec;
import com.vmware.vsphere.client.automation.srv.common.srvapi.VAppSrvApi;

public class EnsureVappIsOnStep extends BaseWorkflowStep {
	private VappSpec _vAppSpec;
	
	@Override
	public void prepare(WorkflowSpec filteredWorkflowSpec) throws Exception {
		_vAppSpec = filteredWorkflowSpec.get(VappSpec.class);
		ensureNotNull(_vAppSpec, "vAppSpec cannot be null");
		
	}
	
	@Override
	public void execute() throws Exception {
		// do not throw an exception unlike in PowerOnVappByApiStep.java. rather do nothing
		VAppSrvApi.getInstance().powerOnVapp(_vAppSpec);
	}
}
