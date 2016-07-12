package com.vmware.vicui.views {

	import com.vmware.core.model.IResourceReference;
	import com.vmware.data.query.events.DataByModelRequest;
	import com.vmware.ui.IContextObjectHolder;
	import com.vmware.vicui.model.ContainerInfo;
	import com.vmware.vicui.constants.AppConstants;
	import com.vmware.vicui.util.AppUtils;
	
	import flash.events.EventDispatcher;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	[Event(name="{com.vmware.data.query.events.DataByModelRequest.REQUEST_ID}",
   type="com.vmware.data.query.events.DataByModelRequest")]

	/**
	 * The mediator for ContainerPortletView
	 */
	public class ContainerPortletMediator extends EventDispatcher implements IContextObjectHolder
	{
	   private var _contextObject:IResourceReference;
	   private var _view:ContainerPortletView;
	
	   private static var _logger:ILogger = Log.getLogger('VicuiMediator');
	
	   [View]
	   /** The view associated with this mediator. */
	   public function set view(value:ContainerPortletView):void {
		   _view = value;
	   }
	   
	   /**
		* Returns the view.
		*/
	   public function get view():ContainerPortletView {
		   return _view;
	   }
	
	
	   [Bindable]
	   /** Returns the inventory object handled in this view (IContextObjectHolder interface) */
	   public function get contextObject():Object {
	      return _contextObject;
	   }
	
	   /** Called by the framework with the current inventory object or null */
	   public function set contextObject(value:Object):void {
	      _contextObject = IResourceReference(value);
	
	      if (_contextObject == null) {
	         // A null contextObject means that the view is being cleared
	         clearData();
	         return;
	      }
	
	      // Once contextObject is set the view can be initialized with the object data.
	      requestData();
	   }
	
	   private function requestData():void {
		   // Dispatch an event to fetch the _contextObject data from the server along the specified model.
		   dispatchEvent(DataByModelRequest.newInstance(_contextObject, ContainerInfo));
	   }
	   
	   [ResponseHandler(name="{com.vmware.data.query.events.DataByModelRequest.RESPONSE_ID}")]
	   public function onData(event:DataByModelRequest, result:ContainerInfo):void {
		   _logger.info("Container summary data retrieved.");
		   if(result != null && _view != null) {
			   
			   var config:Array = result.extraConfig;
			   
			   if (config != null) {
			       _view.isContainer = false;
			       	   
				   for ( var key:String in config ) {
				   	   var item = config[key];
				   	   if(!item.key || !item.key.value) {
				   	       continue;
				   	   }

					   var keyName:String = item.key.value as String;
					   
					   if (keyName == AppConstants.VM_CONTAINER_NAME_PATH) {
					       _view.isContainer = true;
					       _view.containerName.text = item.value as String;
					       continue;
					   }

					   if (keyName == AppConstants.VM_CONTAINER_IMAGE_PATH) {
					   	   _view.imageName.text = item.value as String;
					   	   continue;
					   }
				   }
			   }
		   } else {
			   _view.isContainer = false;
		   }
	   }
	   
	   private function clearData() : void {
	   	   if(_view == null) {
	   	       return;
	   	   }

	      // clear the UI data
		   _view.isContainer = false;
		   _view.containerName.text = null;
	   }
	}
}