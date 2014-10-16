package net.gltd.gtms.controller.muc
{
	import net.gltd.gtms.controller.xmpp.Connection;
	import net.gltd.gtms.events.ConnectionEvent;
	import net.gltd.gtms.events.UserEvent;
	import net.gltd.gtms.events.muc.MUC_UI_Event;
	import net.gltd.gtms.model.dataHolder;
	import net.gltd.gtms.model.muc.ChannelModel;
	import net.gltd.gtms.model.muc.StreamModel;
	import net.gltd.gtms.view.SearchBar;
	import net.gltd.gtms.view.muc.ChannelListBase;
	import net.gltd.gtms.view.muc.InfoChannelContent;
	import net.gltd.gtms.view.muc.NewChannelContent;
	import net.gltd.gtms.view.muc.NewStreamContent;
	
	import flash.display.Screen;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.containers.ViewStack;
	import mx.events.FlexEvent;
	import mx.events.IndexChangedEvent;
	
	import org.igniterealtime.xiff.data.IQ;
	
	import spark.components.Window;
	
	[Event(name="onCreateNewChannel",type="net.gltd.gtms.events.muc.MUC_UI_Event")]
	[Event(name="onUserStartGroupChat",type="net.gltd.gtms.events.UserEvent")]
	[Event(name="onUserOpenStream",type="net.gltd.gtms.events.UserEvent")]
	[ManagedEvents("onCreateNewChannel,onUserStartGroupChat,onUserOpenStream")]
	
	public class MUCManager extends EventDispatcher
	{
		[Inject][Bindable]
		public		var			connection									:Connection;
		
		[Inject][Bindable]
		public		var			mucManager									:MUCInterfaceManager;
		
		[Inject][Bindable]
		public		var			streamsManager								:StreamsManager;
		
		
		private 	var 		defaultSearchFunction						:Function,
								sb											:SearchBar,
								channels									:ChannelListBase,
								streams										:ChannelListBase,
								refreshInterval								:Timer,				
								streamWindow								:Window;
		
		[Init]
		public function init():void {
			//if ( connection.connection.isLoggedIn() )	setTimeout(	initMUCTabs,100);
		}
		
		[MessageHandler (selector="onLoginSuccess")]
		public function onLoginSuccess(event:ConnectionEvent):void {
			setTimeout(function():void {
				try {
					dataHolder.getInstance().interfaces.addEventListener(IndexChangedEvent.CHANGE,onIndexChange);
					sb = dataHolder.getInstance().searchBar;
					defaultSearchFunction = sb.searchFunction;
				}catch (error:Error){
					setTimeout(onLoginSuccess,1000,null);
				}
			},1500);
			
			
		}
		[MessageHandler (selector="onDisconnected")]
		public function onDisconnected(event:ConnectionEvent):void {
			if (refreshInterval!=null){
				
			}
		}
		public function initChannelTab():void {
			channels = new ChannelListBase();
			channels.myKind = ChannelModel.KIND_CHANNEL;
			channels.label = "Channels";
			channels.addEventListener(FlexEvent.SHOW,onChannelsTabOn);
			dataHolder.getInstance().interfaces.addElement( channels );
			dataHolder.getInstance().interfaces.validateNow();
			dataHolder.getInstance().interfaces.validateDisplayList();

		 
			initRefreshTimer();
			
		}
		public function initStremsTab():void {
			streams = new ChannelListBase();
			streams.myKind = StreamModel.KIND_STREAM;
			streams.label = "Streams";
			dataHolder.getInstance().interfaces.addElement( streams );
			dataHolder.getInstance().interfaces.validateNow();
			dataHolder.getInstance().interfaces.validateDisplayList();
			
		}
		
		private function onIndexChange(event:IndexChangedEvent):void {
			if (event.newIndex == 0)sb.searchFunction = defaultSearchFunction;
			else{
				sb.searchFunction = (event.currentTarget as ViewStack).selectedChild['search'];
			} 
			
		}
		[MessageHandler (selector="onShowInfo")]
		public function onShowInfo(event:MUC_UI_Event):void {
			
			mucManager.iqsManager.getDetails( event.item.jid );
			setTimeout(function():void {
				
				var winHeight:uint = Math.min(300, Screen.mainScreen.bounds.height - 110);
				var newWindow:Window = dataHolder.getInstance().getWindow("Channel Information",true,"none",420 ,winHeight,true,true,true,true,"channelInfo");
				newWindow['_container'].bottom += 33;
				
				var content:InfoChannelContent = new InfoChannelContent();
				content.item = event.item;
				newWindow['_container'].addElement( content );
			},900);
		}
		[MessageHandler (selector="onEditChannel")]
		public function onInitEditChannel(event:MUC_UI_Event):void {
			mucManager.iqsManager.askForDetails(event.item.jid,openEditWindow);
		}
		
		[MessageHandler (selector="onEditStream")]
		public function onEditStream(event:MUC_UI_Event):void {
			streamsManager.initEdit(event.item.id);
		}
		
		private function openEditWindow(data:Object,iq:IQ):void {
			var winHeight:uint = Math.min(610, Screen.mainScreen.bounds.height - 110);
			var newWindow:Window = dataHolder.getInstance().getWindow("Create New Channel",true,"none",490,winHeight,true,true,true,true,"newChannel");
			newWindow['_container'].bottom += 33;
			
			var content:NewChannelContent = new NewChannelContent();
			try {
				content.item = mucManager.items.getItemByID( iq.from.bareJID ) as ChannelModel;
			}catch (error:Error){
				
			}
			content.isInfo = true;
			content.data = data;
			
			content.myJID = connection.connection.jid.escaped;
			content.services = mucManager.services;
			content.addEventListener(MUC_UI_Event.CREATE_NEW_CHANNEL,onEditChannel);
			newWindow['_container'].addElement( content );
			
		}
		
		[MessageHandler (selector="onOpenNewWindow")]
		public function onOpenNewWindow(event:MUC_UI_Event):void {
			
			if (event.itemKind == StreamModel.KIND_STREAM){
				streamsManager.initCreate();
				return
			}
			var title:String= title = "Create New Channel";
			var winHeight:uint = Math.min(610, Screen.mainScreen.bounds.height - 110);
			var newWindow:Window = dataHolder.getInstance().getWindow(title,true,"none",450,winHeight,true,true,true,true,"newChannel");
			newWindow['_container'].bottom += 33;
		
		
			var content:NewChannelContent = new NewChannelContent();
			content.myJID = connection.connection.jid.escaped;
			content.services = mucManager.services;
			content.addEventListener(MUC_UI_Event.CREATE_NEW_CHANNEL,onCreateNewChannel);
			newWindow['_container'].addElement( content );
			
		}
		private function onEditChannel(event:MUC_UI_Event):void {
			dispatchEvent( event.clone() );
		}
		
		private function onCreateNewChannel(event:MUC_UI_Event):void {
			dispatchEvent( event.clone() );
		}
		
		[MessageHandler (selector="onOpenNewStreamWindow")]
		public function onOpenNewStreamWindow(event:MUC_UI_Event):void {
			try {
				if (streamWindow!= null && streamWindow.closed == false) streamWindow.close();
				var content:NewStreamContent = new NewStreamContent();
				content.item = event.item;
				content.data = event.xmlData;
				
				var winHeight:uint = Math.min(510, Screen.mainScreen.bounds.height - 110);
				streamWindow = dataHolder.getInstance().getWindow( content.iqObject.command.x.title, true, "none", 450, winHeight, true, true, true, true ,"newStream");
				streamWindow['_container'].bottom += 33;
				streamWindow['_container'].addElement( content );
			}catch (error:Error){
				trace ( error.getStackTrace() );
			}
		}
		
		public function streamItemClick(event:MouseEvent):void {
			var model:StreamModel = event.currentTarget.data;
			var eu:UserEvent = new UserEvent(UserEvent.USER_OPEN_STREAM);
			eu.data = model;
			dispatchEvent(eu);
		}
		
		public function channelItemClick(event:MouseEvent):void {
			openChannel( event.currentTarget.data )
		}
		
		public function openChannel(model:ChannelModel):void {
			if (model.room == null || !model.room.active){
				mucManager.iqsManager.joinRoom(model.jid.unescaped);
			}else {
				var eu:UserEvent = new UserEvent(UserEvent.USER_START_GROUP_CHAT);
				eu.recipientJID = model.room.roomJID;
				eu.data = model.room;
				dispatchEvent(eu);
				
			}
		}
		
		private function initRefreshTimer():void {
			if (refreshInterval!=null && refreshInterval.running)return;
			refreshInterval = new Timer(180000);
			refreshInterval.addEventListener(TimerEvent.TIMER,refreshTick);
			refreshInterval.start();
		}
		
		private function removeRefreshTimer():void {
			if (refreshInterval==null)return;
			refreshInterval.stop();
			refreshInterval.removeEventListener(TimerEvent.TIMER,refreshTick);
			
		}
		
		private function refreshTick(event:TimerEvent):void 
		{
			mucManager.iqsManager.initChannels();
		}
		
		private function onChannelsTabOn(event:FlexEvent):void {
			mucManager.iqsManager.initChannels();
		}
		
	}
}