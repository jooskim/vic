package com.vmware.vsphere.client.automation.vicui.common.step;

import com.vmware.client.automation.workflow.CommonUIWorkflowStep;
import com.vmware.suitaf.apl.IDGroup;

public class ClickSummaryTabStep extends CommonUIWorkflowStep {
	protected final static IDGroup NID_PRIMARY_SUMMARY_TAB = IDGroup.toIDGroup("vm.l1tab.summary");
	
	@Override
	public void execute() throws Exception {
		_logger.info("CHECKING IF PRIMARY TAB EXISTS");
		_logger.info(Boolean.toString(UI.component.exists(NID_PRIMARY_SUMMARY_TAB)));
		
	}

}
