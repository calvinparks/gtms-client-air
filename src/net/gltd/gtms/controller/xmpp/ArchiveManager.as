package net.gltd.gtms.controller.xmpp
{
	import net.gltd.gtms.controller.im.ChatMessageManager;
	import net.gltd.gtms.controller.muc.MUCInterfaceManager;
	import net.gltd.gtms.events.ArchiveEvent;
	import net.gltd.gtms.events.ConnectionEvent;
	import net.gltd.gtms.events.ContactEvent;
	import net.gltd.gtms.model.contact.BuddyModel;
	import net.gltd.gtms.model.contact.IMBuddyModel;
	import net.gltd.gtms.model.contact.singl.buddiesHolder;
	import net.gltd.gtms.model.im.MessageModel;
	import net.gltd.gtms.model.muc.ChannelModel;
	import net.gltd.gtms.model.xmpp.DiscoItemModel;
	
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	import mx.rpc.xml.SimpleXMLDecoder;
	
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.data.IQ;

	
	
	[Event(name="onListReady", type="net.gltd.gtms.events.ArchiveEvent")]
	[Event(name="onTranscriptReady", type="net.gltd.gtms.events.ArchiveEvent")]
	[ManagedEvents("onListReady,onTranscriptReady")]
	public class ArchiveManager extends EventDispatcher
	{
		[Inject]
		public	var		connection			:Connection;
		
		[Inject][Bindable]
		public	var		chatManager			:ChatMessageManager;
		
		[Inject][Bindable]
		public	var		mucManager			:MUCInterfaceManager;
		
		private	var		_xmldecoder			:SimpleXMLDecoder = new SimpleXMLDecoder();
		
		private var 	_archiveDisco		:DiscoItemModel;
		
		private	const	start_date			:String = "2013-03-04T01:20:04.798Z";//"2010-02-22T00:22:21.751Z";
		
		
		
		private var 	idC					:Number = 0;
		private var		tryCounter			:uint = 0;
		
		
		[MessageHandler (selector="onLoginSuccess")]
		public function login(event:ConnectionEvent):void {
			
		}
		[MessageHandler (selector="onDisconnected")]
		public function logout(event:ConnectionEvent):void {
			
			
		}
		[MessageHandler (selector="onNewServiceItem")]
		public function onNewServiceItem(event:ConnectionEvent):void {
			if (connection.disco.getDiscoByFeature("urn:xmpp:archive:manage") != null){
				archiveDisco = connection.disco.getDiscoByFeature("urn:xmpp:archive:manage");
			}
		}
		[MessageHandler (selector="onContactAddedGetArchive")]
		public function onContactAdded(event:ArchiveEvent):void {  
			setTimeout(getChatListFor,200,event.forJID.bareJID,-1);
			
		}
		
		[MessageHandler (selector="onGetList")]
		public function onGetList(event:ArchiveEvent):void {
			try {
				setTimeout(getChatListFor,900,event.forJID.bareJID,-1,true);
			}catch (error:Error){
			
			}
		
		}
		[MessageHandler (selector="onGetConversation")]
		public function onGetConversation(event:ArchiveEvent):void {
			try {
				var mm:MessageModel = chatManager.recipientList.getItemByID(event.forJID.bareJID) as MessageModel;
				getChat(event.forJID.bareJID,event.date,-1,chatForChatresponse);
			}catch (er:Error){
				trace (er.getStackTrace());	
			}
		}
		
		private function set archiveDisco(m:DiscoItemModel):void {
			if (_archiveDisco == null){
				_archiveDisco = m;
				return;
			}
			_archiveDisco = m;
			
		}
		private function get archiveDisco():DiscoItemModel {
			return _archiveDisco;
		}
		public function getConversatioCounter(withWho:String, startDate:String="2000-02-17T18:17:30.059Z"):void {
			var iq:IQ = new IQ(archiveDisco.jid,"get",null,saveCounter,saveCounter);
			var listNode:XMLNode = new XMLNode(1,"retrieve");
			listNode.attributes['xmlns'] = "urn:xmpp:archive";
			listNode.attributes['with'] = withWho;
			listNode.attributes['start'] = startDate;
			
			var setNode:XMLNode = new XMLNode(1,"set");
			setNode.attributes.xmlns = "http://jabber.org/protocol/rsm";
			
			listNode.appendChild(setNode);
			
			var maxNode:XMLNode = new XMLNode(1,"max");
			var maxNodeValue:XMLNode = new XMLNode(2,"1");
			maxNode.appendChild(maxNodeValue);
		
			
			setNode.appendChild( maxNode );
			iq.xml.appendChild( new XML(listNode) );
			connection.send(iq);
		}
		private function saveCounter(iq:IQ):void {
			try {
				var obj:Object = _xmldecoder.decodeXML( new XMLDocument(iq.xml).firstChild );
				var mm:MessageModel = chatManager.recipientList.getItemByID(obj.chat['with']) as MessageModel;
				if (isNaN(mm.archiveCount) || mm.archiveCount != Number(obj.chat.set.count))mm.archiveCount = Number(obj.chat.set.count);
				if (mm.archiveCount > 0 && mm.archives.length == 0){
					setTimeout(getConversationWith,250,obj.chat['with'], start_date,mm.archiveBeforeValue,mm.archiveOffset);
				}
			
			}catch (error:Error){
				
			}
		}
		public function getConversationWith(withWho:String, startDate:String="2000-02-17T18:17:30.059Z",before:int=0,max:int=100):void {
			var iq:IQ = new IQ(archiveDisco.jid,"get",null,getConversationResponse,getConversationResponse);
			var listNode:XMLNode = new XMLNode(1,"retrieve");
			listNode.attributes['xmlns'] = "urn:xmpp:archive";
			listNode.attributes['with'] = withWho;
			listNode.attributes['start'] = startDate;
			
			var setNode:XMLNode = new XMLNode(1,"set");
			setNode.attributes.xmlns = "http://jabber.org/protocol/rsm";
			
			listNode.appendChild(setNode);
			
			var maxNode:XMLNode = new XMLNode(1,"max");
			var maxNodeValue:XMLNode = new XMLNode(2,max.toString());
			maxNode.appendChild(maxNodeValue);
			
			var afterNode:XMLNode = new XMLNode(1,"before");
			var afterNodeValue:XMLNode = new XMLNode(2,before.toString() );
			afterNode.appendChild(afterNodeValue);
			
			
			setNode.appendChild( maxNode );
			setNode.appendChild( afterNode );
			iq.xml.appendChild( new XML(listNode));
			connection.send(iq);
		}
		public function getChat(withWho:String, startDate:String,max:int=-1,callBack:Function=null,tryCounter:uint=0):void {
			if (callBack==null)callBack = getChatResponse;
			else if (callBack == chatForChatresponse) callBack = chatForChatresponse(tryCounter)
			var iq:IQ = new IQ(archiveDisco.jid,"get",null,callBack,callBack);
			var listNode:XMLNode = new XMLNode(1,"retrieve");
			listNode.attributes['xmlns'] = "urn:xmpp:archive";
			listNode.attributes['with'] = withWho;
			listNode.attributes['start'] = startDate;
			
			var setNode:XMLNode = new XMLNode(1,"set");
			setNode.attributes.xmlns = "http://jabber.org/protocol/rsm";
			
			listNode.appendChild(setNode);
			
			var maxNode:XMLNode = new XMLNode(1,"max");
			var maxNodeValue:XMLNode = new XMLNode(2,max.toString());
			maxNode.appendChild(maxNodeValue);
			
			
			setNode.appendChild( maxNode );
			iq.xml.appendChild( new XML(listNode));
			connection.send(iq);
			
		}
		
		
		public function getChatListFor(withWho:String,max:int=1000,forChatWindow:Boolean=false): void {

			if (archiveDisco == null){
				// sprubuj2 razy;
				if (++tryCounter == 4) return;
				setTimeout(getChatListFor,2000,withWho,max);
				return
			}
			
			var iq:IQ = new IQ(archiveDisco.jid,"get",null,getChatListResponse,getChatListResponse);
			if (forChatWindow)iq.id = withWho+"_lw"+(++idC);
			else iq.id = withWho+"_l"+(++idC);
			
			var listNode:XMLNode = new XMLNode(1,"list");
			listNode.attributes.xmlns = "urn:xmpp:archive";
			listNode.attributes['with'] = withWho;
			var setNode:XMLNode = new XMLNode(1,"set");
			setNode.attributes.xmlns = "http://jabber.org/protocol/rsm"
				
			listNode.appendChild(setNode);
			
			var maxNode:XMLNode = new XMLNode(1,"max");
			var maxNodeValue:XMLNode = new XMLNode(2,max.toString());
			maxNode.appendChild(maxNodeValue);
			
			setNode.appendChild( maxNode );
			iq.xml.appendChild( new XML(listNode));
			
			connection.send(iq);
			
			
		}
		
		private function chatForChatresponse(tryCounter:uint=0):Function {
			
			return function(iq:IQ):void {
				var obj:Object;
				try {
				
					 obj = _xmldecoder.decodeXML(new XMLDocument(iq.xml).firstChild);
					 var mm:MessageModel;
					 if (obj.hasOwnProperty("error")){
						 if (tryCounter == 3){
							 mm =  chatManager.recipientList.getItemByID(obj.retrieve['with']) as MessageModel;
							 mm.archiveChatError();
							 return 
						 }
						 setTimeout( getChat, 1000, obj.retrieve['with'],obj.retrieve['start'],1,chatForChatresponse,++tryCounter);
						 return;
					 }
					mm = chatManager.recipientList.getItemByID(obj.chat['with']) as MessageModel;
					
					if (mm==null)mm.archiveChatError();
					else mm.displayArchiveChat (getConversationArray(obj) )
				}catch (error:Error){
					trace (error.getStackTrace())
				}
			}
			
		}
		private function getChatResponse(iq:IQ):void {
			var obj:Object = _xmldecoder.decodeXML(new XMLDocument(iq.xml).firstChild);
			obj.all = getConversationArray(obj);
			try {
				var event:ArchiveEvent = new ArchiveEvent(ArchiveEvent.TRANSCRIPT_READY,new EscapedJID(obj.chat['with']),null,obj);
				dispatchEvent(event);
			}catch (error:Error){
				
			}
			
		}
		
		private function getConversationArray(obj:Object):Array {
			var all:Array = [];
			try {
				if (obj.chat.from != undefined) all = all.concat(obj.chat.from);
				if (obj.chat.to != undefined) all = all.concat(obj.chat.to);
				all.sortOn("secs",Array.NUMERIC);
			}catch (error:Error){

			}
			return all;
		}
		
		
		private function getConversationResponse(iq:IQ):void {
			var obj:Object = _xmldecoder.decodeXML( new XMLDocument(iq.xml).firstChild );
			if ( !obj.chat )return;
			
			try {
				var mm:MessageModel = chatManager.recipientList.getItemByID(obj.chat['with']) as MessageModel;
				mm.archiveCurrentScopeInc();
				mm.archiveStart = obj.chat.start;
				saveCounter(iq);
		
				var all:Array = [];
				if (obj.chat.from != undefined) all = all.concat(obj.chat.from);
				if (obj.chat.to != undefined) all = all.concat(obj.chat.to);
				
				mm.contactArchive ( all );
				
			}catch (error:Error){
				
			}
			
			var event:ArchiveEvent = new ArchiveEvent(ArchiveEvent.CONVERSATION_READY)
		}
		private function getChatListResponse(iq:IQ):void {
			var obj:Object;
			try {
				obj = _xmldecoder.decodeXML( new XMLDocument(iq.xml).firstChild );
				if (! obj.list.chat)return;
				var bd:BuddyModel = buddiesHolder.getInstance().getBuddy( iq.id.split("_l")[0] );
				var item:Object;
				if (bd==null){
					//trace ("PEWNIE TO CHANNEL O ID", iq.id.split("_l")[0]);
					item = mucManager.items.getItemByID(  iq.id.split("_l")[0] );
				}else {
					item = bd;
				}
				//if (item.hasOwnProperty("roster") ){
					if ( !(obj.list.chat is Array) )  obj.list.chat = [ obj.list.chat ];
					item.archiveList = [];
					item.archiveGrList = [];
					for (var i:uint =0; i<  obj.list.chat.length;i++){
						if (item.id ==  obj.list.chat[i]['with']){
							item.archiveList.push( obj.list.chat[i] );
						}else {
							item.archiveGrList.push( obj.list.chat[i] );
						}
					} 
				//	(bd as IMBuddyModel).archiveList =  obj.list.chat;
					item.archiveList.sortOn("start");
				//}
				
				try { 
					if (iq.id.indexOf("_lw") > -1){
						var mm:MessageModel = chatManager.recipientList.getItemByID(item.id) as MessageModel;
						if (mm!=null){
							mm.archiveCount = item.archiveList.length;//obj.list.chat.length;
							mm.getNewArchiveConversation();
						}
					}
				}catch (error:Error){
					trace ( error.getStackTrace() );
				}
			}catch (error:Error){
				trace ( error.getStackTrace() );
			}
		
			
		
		}
		
		public static function convertToDate(s:String,inc:Number=0):Date {
			var a:Array = s.slice(0,s.indexOf("T")).split("-");
			var t:Array = s.slice( s.indexOf("T")+1, s.indexOf(".") ).split(":");
			var _startDate:Date = new Date();
			_startDate.fullYear = a[0];
			_startDate.month = a[1] - 1;
			_startDate.date = a[2];
			_startDate.minutes = Number(t[1]);
			_startDate.seconds = Number(t[2]) + inc;
			_startDate.hours = t[0];
			return  _startDate;
			
		}
		
		 
	}
	
}