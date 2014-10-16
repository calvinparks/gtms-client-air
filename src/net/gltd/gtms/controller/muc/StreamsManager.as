package net.gltd.gtms.controller.muc
{
	import net.gltd.gtms.controller.app.SettingsManager;
	import net.gltd.gtms.events.muc.MUC_UI_Event;
	import net.gltd.gtms.model.app.AllertSettingsModel;
	import net.gltd.gtms.model.muc.StreamModel;
	import net.gltd.gtms.model.xmpp.DiscoItemModel;
	import net.gltd.gtms.utils.FilterArrayCollection;
	import net.gltd.gtms.utils.StringUtils;
	
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.xml.SimpleXMLDecoder;
	
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.data.IQ;
	import org.igniterealtime.xiff.data.XMLStanza;
	import org.igniterealtime.xiff.data.XMPPStanza;

	[Event(name="onOpenNewStreamWindow",type="net.gltd.gtms.events.muc.MUC_UI_Event")]
	[ManagedEvents("onOpenNewStreamWindow")]
	public class StreamsManager extends EventDispatcher
	{
		
		[Inject]
		public	var		iqsManager						:MUCXMPPManager;
		
		private	var		//_streamsCollection				:ArrayCollection = new ArrayCollection(),
						_xmlDecoder						:SimpleXMLDecoder = new SimpleXMLDecoder(),
						_sessionid						:String,
						_fields							:Object = {};
		
		
		public	static	const	NODE_ACTION_SEARCH		:String = "http://gltd.net/protocol/chatstream:01:00:00#search-streams",
								NODE_ACTION_EDIT		:String = "http://gltd.net/protocol/chatstream:01:00:00#edit-stream",
								NODE_ACTION_DELETE		:String = "http://gltd.net/protocol/chatstream:01:00:00#delete-stream",
								NODE_ACTION_CREATE		:String = "http://gltd.net/protocol/chatstream:01:00:00#create-stream",
								
								ACTION_EXECUTE			:String = "execute";
		
		
		

		
		public function get services():FilterArrayCollection {
			return iqsManager.streamsServices;
		}
		
		public function init():void {
			for (var i:uint = 0; i< services.length; i++){
				initStreams( (services.getItemAt(i) as DiscoItemModel).jid ); 
			}
			if (services.length > 0 && !iqsManager.mucInterfaceManager.streams_enabled)iqsManager.mucInterfaceManager.streams_enabled = true;
		}
		
		
		public function get streamsCollection_hmm():ArrayCollection {
			return null;//_streamsCollection;
		}
		
		
		public function deleteStream(id:String):void {
			var service:EscapedJID = service = services.getItemAt(0).jid;
			
			var fieldNode:XMLNode = new XMLNode(1,"field");
			
			fieldNode.attributes.type = 'text-single';
			fieldNode.attributes['var'] = 'id';
			
			var fieldValueNode:XMLNode = new XMLNode(1,"value");
			var fieldValueNodeValue:XMLNode = new XMLNode(3,id);
			
			fieldValueNode.appendChild(fieldValueNodeValue);
			fieldNode.appendChild(fieldValueNode);
			
		
			sendAction(service,NODE_ACTION_DELETE,deleteCallBack(fieldNode,id),ACTION_EXECUTE,null,fieldNode);
		}
		
		
		public function initCreate(service:EscapedJID=null):void {
			if (service==null)service = services.getItemAt(0).jid;
			sendAction(service,NODE_ACTION_CREATE,createInitCallBack);
		}
		public function initEdit(id:String):void {
			sendAction( services.getItemAt(0).jid, NODE_ACTION_EDIT, createEditCallBack, "execute", id+"_edit"+StringUtils.generateRandomString(4));
		}
		public function initStreams( service:EscapedJID, field:XMLNode=null ):void {
			
			sendAction(service,NODE_ACTION_SEARCH,initCallBack,ACTION_EXECUTE,null,field);
		}
		
		private function sendAction(service:EscapedJID, node:String,callback:Function,action:String = ACTION_EXECUTE,id:String=null,fieldNode:XMLNode=null):void{
			if (service==null)service = services.getItemAt(0).jid;
			var iq:IQ = new IQ(service,"set",id,callback,callback);
		
			var commandNode:XMLNode = new XMLNode(1,"command");
			commandNode.attributes.xmlns = "http://jabber.org/protocol/commands";
			commandNode.attributes.node = node;
			commandNode.attributes.action = action;
			iq.xml.appendChild( new XML(commandNode) );
			if (fieldNode!=null)_fields[iq.id] = fieldNode;
			iqsManager.connection.send( iq );
		}
		private function initCallBack(iq:IQ):void {
			if (iq.type == IQ.TYPE_ERROR) return;
			try {
				var field:XMLNode;
				if (_fields[iq.id] != undefined){
					field = _fields[iq.id];
					delete _fields[iq.id];
				}
				_sessionid = iq.xml.children().attribute('sessionid');
				doStreamAction(iq.from,NODE_ACTION_SEARCH,_sessionid,field);
			}catch (error:Error){

			}
		}
		
		private function doStreamAction( service:EscapedJID, node:String, sessionID:String ,fieldNode:XMLNode=null):void {
			if (service==null)service=services.getItemAt(0).jid;
			if (sessionID==null)sessionID = _sessionid;
			var iq:IQ = new IQ(service,"set",null,getCallBack,getCallBack);
			var commandNode:XMLNode = new XMLNode(1,"command");
			commandNode.attributes.xmlns = "http://jabber.org/protocol/commands";
			commandNode.attributes.node = node;
			commandNode.attributes.sessionid = sessionID;
	 
			   
			var xNode:XMLNode = new XMLNode(1,"x");
			xNode.attributes.xmlns ="jabber:x:data";
			xNode.attributes.type = "submit";
			
			var filed:XML = <field var="FORM_TYPE" type="hidden">
							<value>http://gltd.net/protocol/chatstream:01:00:00</value>
						</field>;
			
			
			xNode.appendChild( new XMLDocument(filed.toString()).firstChild );
			if(fieldNode!=null){
				xNode.appendChild(fieldNode);
			}
			
			
			commandNode.appendChild( xNode );
			iq.xml.appendChild(new XML(commandNode) ); 
			iqsManager.connection.send( iq );
			
		}
		private function getCallBack(iq:IQ):void {
			try {
				var obj:Object = _xmlDecoder.decodeXML( new XMLDocument(iq.xml).firstChild );
				if (!obj.command.hasOwnProperty("x"))return;
				var items:Array;
				if (obj.command.x.item is Array)items = obj.command.x.item;
				else items = [obj.command.x.item];
				for (var i:uint = 0; i < items.length; i++){
					var model:StreamModel;
					for (var j:uint = 0; j<items[i].field.length; j++){
						var id:String;
						try {
							if(items[i].field[j]['var'] == "id"){
								id = items[i].field[j]['value']
			
							}
						}catch (error:Error){
							
						}
					} 
					var isNew:Boolean;
					if (iqsManager.mucInterfaceManager.items.getItemIndexByID(id) > -1){
						model = iqsManager.mucInterfaceManager.items.getItemByID( id ) as StreamModel;
					}else {
						model = new StreamModel();
						isNew = true;
					}
					for ( j = 0; j<items[i].field.length; j++){
						try {
							if (model.hasOwnProperty(items[i].field[j]['var']) && model[ items[i].field[j]['var'] ] is Boolean) { 
								model[ items[i].field[j]['var'] ] = Boolean(items[i].field[j]['value']);
							}
							else model[ items[i].field[j]['var'] ] = items[i].field[j]['value'];
						}catch (error:Error){ 
						
						}
					} 
					model.sourceObject = obj;
					if (isNew)	iqsManager.mucInterfaceManager.items.addItem( model );
				
				}
				iqsManager.mucInterfaceManager.items.refresh();
			}catch (error:Error){
				trace (error.getStackTrace());
			}
			iqsManager.getSubscriptions();
		
		}
		private function createEditCallBack(iq:IQ):void {
			if (iq.type == IQ.TYPE_ERROR){
				if ( (SettingsManager.ALLERTS["notificationError"] as AllertSettingsModel).popup == true ){
					//UEM.newUEM(iq.id+"error",iq,msg,[new UEMfeature(UIphrases.IM_MSG_EVENT_BUTTON_READ,uemReadHandeler,[m.from.bareJID])],null,SettingsManager.ALLERTS["notificationIM"].time);
					
				}
				return;
			}
			var ev:MUC_UI_Event = new MUC_UI_Event(MUC_UI_Event.OPEN_NEW_STREAM_WINDOW);
			ev.xmlData = iq;
			ev.item = iqsManager.mucInterfaceManager.items.getItemByID(iq.id.split("_").shift())
			dispatchEvent(ev);
			
		}
		private function createInitCallBack(iq:IQ):void {
			if (iq.type == IQ.TYPE_ERROR){
				if ( (SettingsManager.ALLERTS["notificationError"] as AllertSettingsModel).popup == true ){
					//UEM.newUEM(iq.id+"error",iq,msg,[new UEMfeature(UIphrases.IM_MSG_EVENT_BUTTON_READ,uemReadHandeler,[m.from.bareJID])],null,SettingsManager.ALLERTS["notificationIM"].time);
				
				}
				return;
			}
			var ev:MUC_UI_Event = new MUC_UI_Event(MUC_UI_Event.OPEN_NEW_STREAM_WINDOW);
			ev.xmlData = iq;
			dispatchEvent(ev);
		}
		private function deleteCallBack(field:XMLNode,id:String):Function {
			return function (iq:IQ):void {
				doStreamAction(null,NODE_ACTION_DELETE, iq.xml.children().attribute('sessionid'), field);
				try {
					iqsManager.mucInterfaceManager.items.removeByID( id );
					iqsManager.mucInterfaceManager.items.refresh();
				}catch (error:Error){

				}
				setTimeout(initStreams,2200,null);
				
			}
		}
		
	}
}