package com.vmware.vicui.views {

	import com.vmware.core.model.IResourceReference;
	import com.vmware.data.query.events.DataByModelRequest;
	import com.vmware.data.query.events.DataRequestInfo;
	import com.vmware.data.query.DataUpdateSpec;
	import com.vmware.ui.IContextObjectHolder;
	import com.vmware.vicui.model.VchInfo;
	import com.vmware.vicui.constants.AppConstants;
	
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.Base64Decoder;
	
	[Event(name="{com.vmware.data.query.events.DataByModelRequest.REQUEST_ID}",
   type="com.vmware.data.query.events.DataByModelRequest")]

	/**
	 * The mediator for ContainerPortletView
	 */
	public class VchPortletMediator extends EventDispatcher implements IContextObjectHolder
	{
	   private var _contextObject:IResourceReference;
	   private var _view:VchPortletView;
	
	   private static var _logger:ILogger = Log.getLogger('VchMediator');
	
	   [View]
	   /** The view associated with this mediator. */
	   public function set view(value:VchPortletView):void {
		   _view = value;
	   }
	   
	   /**
		* Returns the view.
		*/
	   public function get view():VchPortletView {
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
	   	   // Default data request option allowing implicit updates of the view
	   	   var requestInfo:DataRequestInfo = new DataRequestInfo(DataUpdateSpec.newImplicitInstance());

		   // Dispatch an event to fetch the _contextObject data from the server along the specified model.
		   dispatchEvent(DataByModelRequest.newInstance(_contextObject, VchInfo, requestInfo));
	   }
	   
	   [ResponseHandler(name="{com.vmware.data.query.events.DataByModelRequest.RESPONSE_ID}")]
	   public function onData(event:DataByModelRequest, result:VchInfo):void {
		   _logger.info("Vch summary data retrieved.");

		   if(result != null && _view != null) {
			   var base64Decoder:Base64Decoder = new Base64Decoder();
			   var config:Array = result.extraConfig;
			   
			   if (config != null) {
			   	   _view.isVch = false;

				   for ( var key:String in config ) {
					   var keyName:String = config[key].key.value as String;
					   
					   if (keyName == AppConstants.VCH_NAME_PATH) {
					       _view.isVch = true;
					       continue;
					   }
						
					   if (keyName == AppConstants.VCH_CLIENT_IP_PATH ) {
					       base64Decoder.decode(config[key].value as String);

					       var bytes:ByteArray = base64Decoder.toByteArray();
					       var ip_raw:String = bytes.toString();
					       var ip_ipv4:String = ip_raw.charCodeAt(0) + "." + ip_raw.charCodeAt(1) + "." + ip_raw.charCodeAt(2) + "." + ip_raw.charCodeAt(3);
					       
					       _view.dockerApiEndpoint.text = "DOCKER_HOST=tcp://" + ip_ipv4 + ":2376";
					       _view.dockerLog.label = "http://" + ip_ipv4 + ":2378";
					       continue;

					   }

				   }
			   }
		   } else {
			   _view.isVch = false;
		   }
	   }
	   
	   private function clearData() : void {
	   	   if(_view == null) {
	   	       return;
	   	   }
	      // clear the UI data
		   _view.isVch = false;
		   _view.dockerApiEndpoint.text = new String("");
		   _view.dockerLog.label = new String("");
	   }
	}
}