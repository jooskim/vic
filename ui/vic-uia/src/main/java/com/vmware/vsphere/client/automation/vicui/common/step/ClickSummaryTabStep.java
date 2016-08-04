package com.vmware.vsphere.client.automation.vicui.common.step;

import com.vmware.client.automation.workflow.CommonUIWorkflowStep;
import com.vmware.suitaf.apl.IDGroup;

public class ClickSummaryTabStep extends CommonUIWorkflowStep {
	// This step is used to resolve the tab navigation issue on vCenter 6.0
	
	@Override
	public void execute() throws Exception {
		LegacyPrimaryTabNav summaryNav = new LegacyPrimaryTabNav();
		summaryNav.selectPrimaryTab("Summary");
		
	}

}
