package com.vmware.vicui.views {

	import com.vmware.core.model.IResourceReference;
	import com.vmware.data.query.events.DataByModelRequest;
	import com.vmware.ui.IContextObjectHolder;
	import com.vmware.vicui.model.VchInfo;
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
		   // Dispatch an event to fetch the _contextObject data from the server along the specified model.
		   dispatchEvent(DataByModelRequest.newInstance(_contextObject, VchInfo));
	   }
	   
	   [ResponseHandler(name="{com.vmware.data.query.events.DataByModelRequest.RESPONSE_ID}")]
	   public function onData(event:DataByModelRequest, result:VchInfo):void {
		   _logger.info("Vch summary data retrieved.");
		   if(result != null) {
			   
			   var config:Array = result.extraConfig;
			   
			   var arry:String;
			   
			   if (config != null) {
	   
				   for ( var key:String in config ) {
					   
					   var keyName:String = config[key].key.value as String;
					   
					   arry += keyName;
					   arry += ": ";
					   arry += config[key].value;
					   arry += "\n";
					   
					   //vch name
					   var indexNum:int = AppUtils.findIndexOfValue(config, AppConstants.VCH_NAME_PATH);
					   if (indexNum !== -1) {
						   _view.isVch= true;
					   }
					   else {
						   _view.isVch = false;
					   }
				   }
				   
				   //_view.vchConfig.text = arry;
			   }
		   } else {
			   _view.isVch = false;
		   }
	   }
	   
	   private function clearData() : void {
	      // clear the UI data
		   _view.isVch = false;
	   }
	}
}