package com.vmware.vsphere.client.automation.vicui.plugininstalled.step;

import com.vmware.client.automation.workflow.CommonUIWorkflowStep;
import com.vmware.suitaf.apl.IDGroup;
import com.vmware.vsphere.client.automation.vicui.common.ComponentAutomationNames;

public class FindVicUIStep extends CommonUIWorkflowStep {

	@Override
	public void execute() throws Exception {
		verifyFatal(UI.component.exists(ComponentAutomationNames.ADMINISTRATION_CLIENTPLUGINS_VICUI), "Chekcing if VIC UI is installed properly");
	}
}
