package com.vmware.vicui;

import java.util.ArrayList;
import java.util.List;

import com.vmware.vise.data.query.DataServiceExtensionRegistry;
import com.vmware.vise.data.query.PropertyRequestSpec;
import com.vmware.vise.data.query.PropertyValue;
import com.vmware.vise.data.query.ResultSet;
import com.vmware.vise.data.query.ResultItem;
import com.vmware.vise.data.query.TypeInfo;

public class VicUIServiceImpl implements VicUIService {
	private static final String[] VIC_VM_TYPES = {"isVCH", "isContainer"};
	
	public VicUIServiceImpl(DataServiceExtensionRegistry extensionRegistry) {
		TypeInfo vmTypeInfo = new TypeInfo();
		vmTypeInfo.type = "VirtualMachine";
		vmTypeInfo.properties = VIC_VM_TYPES;
		TypeInfo[] providerTypes = new TypeInfo[] { vmTypeInfo };
		
		extensionRegistry.registerDataAdapter(this, providerTypes);
	}
   
	@Override
	public ResultSet getProperties(PropertyRequestSpec propertyRequest) {
		ResultSet resultSet = new ResultSet();
		
		try {
			List<ResultItem> resultItems = new ArrayList<ResultItem>();
			
			for (Object objRef : propertyRequest.objects) {
				ResultItem resultItem = getProperties(objRef);
				if (resultItem != null) {
					resultItems.add(resultItem);
				}
			}
			
			resultSet.items = resultItems.toArray(new ResultItem[] {});
			
		} catch (Exception e) {
			
		}
			
		return resultSet;
	}
	
	private ResultItem getProperties(Object objRef) {
		ResultItem resultItem = new ResultItem();
		resultItem.resourceObject = objRef;
		
		PropertyValue pv_is_vch = new PropertyValue();
		pv_is_vch.resourceObject = objRef;
		pv_is_vch.propertyName = VIC_VM_TYPES[0];
		pv_is_vch.value = false;
		
		PropertyValue pv_is_container = new PropertyValue();
		pv_is_container.resourceObject = objRef;
		pv_is_container.propertyName = VIC_VM_TYPES[1];
		pv_is_container.value = false;
		
		resultItem.properties = new PropertyValue[] {pv_is_vch, pv_is_container};
		
		return resultItem;
	}
}
