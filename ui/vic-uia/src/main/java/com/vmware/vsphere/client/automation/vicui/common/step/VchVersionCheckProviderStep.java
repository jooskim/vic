package com.vmware.vsphere.client.automation.vicui.common.step;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.vmware.client.automation.workflow.explorer.SettingsReader;
import com.vmware.client.automation.workflow.explorer.SettingsWriter;
import com.vmware.client.automation.workflow.provider.AssemblerSpec;
import com.vmware.client.automation.workflow.provider.ProviderWorkflowStep;
import com.vmware.client.automation.workflow.provider.PublisherSpec;
import com.vmware.vsphere.client.automation.provider.commontb.CommonTestBedProvider;
import com.vmware.vsphere.client.automation.srv.common.spec.VcSpec;

public class VchVersionCheckProviderStep implements ProviderWorkflowStep {
	private VcSpec _vcSpec;
	private static final Logger _logger = LoggerFactory.getLogger(VchVersionCheckProviderStep.class);

	public void assemble(SettingsWriter arg0) throws Exception {
		// TODO Auto-generated method stub
	}

	public boolean checkHealth() throws Exception {	
		return true;
	}

	public void disassemble() throws Exception {
		// TODO Auto-generated method stub
		
	}

	public void prepare(PublisherSpec publisherSpec, AssemblerSpec assemblerSpec, boolean isAssembling,
			SettingsReader settingsReader) throws Exception {
		// TODO Auto-generated method stub
		
	}
	
	
}
