/*
** DiscoManager.as , package net.gltd.gtms.controller.xmpp **  
* 
*	 Globility Limited
* 
*	 Copyright 2012. All rights reserved. 
* 
*	 Author: Piotr Kownacki ( pinczo@pinczo.net )
*	 pinczo 
*	 communified_v3.1 
*	 Created: Jun 12, 2012 
*
*
*/ 
package net.gltd.gtms.controller.xmpp
{
	import net.gltd.gtms.events.ConnectionEvent;
	import net.gltd.gtms.model.xmpp.DiscoItemModel;
	import net.gltd.gtms.utils.FilterArrayCollection;
	
	import flash.events.EventDispatcher;
	import flash.utils.clearInterval;
	import flash.utils.setTimeout;
	
	import org.igniterealtime.xiff.core.Browser;
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.data.IQ;
	import org.igniterealtime.xiff.data.disco.InfoDiscoExtension;
	import org.igniterealtime.xiff.data.disco.ItemDiscoExtension;

	[Event(name="onConnectionSucces",type="net.gltd.gtms.events.ConnectionEvent")]
	[ManagedEvents("onNewServiceItem")]
	
	public class DiscoManager extends EventDispatcher
	{
		[Inject][Bindable]
		public			var			conn					:Connection;
		
		private			var			_discoItems				:FilterArrayCollection,
									_tO						:uint;
		
		public			var			browser					:Browser;
		
		
		[Init]
		public function init():void {
		}
		
		[Bindable]
		public function get discoItems():FilterArrayCollection {
			return _discoItems;	
		}
		public function set discoItems(f:FilterArrayCollection):void {
			_discoItems = f;
		}
		
		public function getDiscoByName(name:String):DiscoItemModel {
			if (_discoItems == null)return null;
			for (var i:uint = 0; i<_discoItems.length; i++){
				try {
					if ( (_discoItems.getItemAt(i) as DiscoItemModel).name.toLowerCase() == name.toLowerCase()){
						return _discoItems.getItemAt(i) as DiscoItemModel;
					}
				}catch (error:Error){
				}
			}
			
			return null;
		}
		public function getDiscoByNameAndId(name:String):DiscoItemModel {
			if (_discoItems == null)return null;
			name = name.toLowerCase()
			for (var i:uint = 0; i<_discoItems.length; i++){
				try {
					if ( (_discoItems.getItemAt(i) as DiscoItemModel).name.toLowerCase() == name && (_discoItems.getItemAt(i) as DiscoItemModel).id.toLowerCase().indexOf(name) == 0 ){
						return _discoItems.getItemAt(i) as DiscoItemModel;
					}
				}catch (error:Error){
				}
			}
			
			return null;
		}
		public function getDiscoByJID(id:String):DiscoItemModel {
			if (_discoItems == null)return null
			return _discoItems.getItemByID(id) as DiscoItemModel;
		}
		public function getItemsByName(id:String):Array {
			if (_discoItems == null)return null;
			var a:Array = [];
			for (var i:uint = 0; i< _discoItems.length;i++){
				if (_discoItems.getItemAt(i).name == id){
					a.push(_discoItems.getItemAt(i))
				}
			}
			return a;
		}
	 
		public function getDiscoByCategory(category:String):Vector.<DiscoItemModel> {
			try {
				var items:Vector.<DiscoItemModel> = new Vector.<DiscoItemModel>();
				for (var i:uint = 0 ; i < _discoItems.length; i++){
					var it:DiscoItemModel = _discoItems.getItemAt(i) as DiscoItemModel;
					for (var j:uint = 0; j < it.identities.length; j++){
						if (it.identities[j].category == category) items.push( it );
					}
				}
			}catch (error:Error){
				
			}
			return items
		}
		public function getDiscoByFeature(id:String):DiscoItemModel {
			try {
				for (var i:uint = 0 ; i < _discoItems.length; i++){
					var it:DiscoItemModel = _discoItems.getItemAt(i) as DiscoItemModel;
					for (var j:uint = 0; j < it.identities.length; j++){
						if (it.identities[j].features.toString().indexOf(id) > -1) return it;
					}
				}
			}catch (error:Error){
				
			}
			return null
		}
		public function getDisco():Array {
			if (_discoItems == null)return null
			return _discoItems.source;
		}
			
		[MessageHandler (selector="onLoginSuccess")]
		public function connected(event:ConnectionEvent):void {
			var serverJID:EscapedJID;
			if (conn.connection.domain == null || conn.connection.domain == ""){
				serverJID = new EscapedJID(conn.connection.server)
			}else {
				serverJID = new EscapedJID(conn.connection.domain);
			}
			_discoItems = new FilterArrayCollection();
			browser = new Browser(conn.connection);
			browser.getServiceItems(serverJID, serviceItemsCall);
			_discoItems.addItem( new DiscoItemModel( serverJID.toString(), null, serverJID) );
			browser.getServiceInfo(serverJID,populateServicesFromInfo,errorServicesFromInfo);
			clearInterval(_tO);
			_tO = setTimeout(dispatch, 9000);
		}
		private function dispatch(item:DiscoItemModel=null):void {
			var ev:ConnectionEvent = new ConnectionEvent(ConnectionEvent.NEW_SERVICE_ITEM);
			ev.data = item;
			dispatchEvent (ev)
		}
		public function serviceItemsCall(iq:IQ):void
		{
			var extensions:Array = iq.getAllExtensionsByNS(ItemDiscoExtension.NS);
			if (extensions == null) return;
			var itemExt:ItemDiscoExtension = extensions[0];
			
			for each(var item:Object in itemExt.items) {
				_discoItems.addItem( new DiscoItemModel( item.jid.toString(), item.name, new EscapedJID(item.jid.toString()) ) )
				getServiceInfo( new EscapedJID(item.jid) )
			}
		
		}
		public function getServiceInfo(jid:EscapedJID):void {
			browser.getServiceInfo(jid,populateServicesFromInfo,errorServicesFromInfo)
		}
		public function errorServicesFromInfo(iq:IQ):void {
				trace ("disco error:",iq.xml);
		}
		public function populateServicesFromInfo(iq:IQ):void
		{
			var extensions:Array = iq.getAllExtensionsByNS(InfoDiscoExtension.NS);
	
			if (extensions == null)return;
			var infoExt:InfoDiscoExtension = extensions[0]; 
			(_discoItems.getItemByID(iq.from.bareJID) as DiscoItemModel).resetIdentitys();
			for each(var identity:* in infoExt.identities)
			{
				(_discoItems.getItemByID(iq.from.bareJID) as DiscoItemModel).setIdentity( {	name	:	identity.name,	type	: 	identity.type,	category	:	identity.category,	features:	infoExt.features } )
			}
			dispatch( _discoItems.getItemByID(iq.from.bareJID) as DiscoItemModel  );
			//clearInterval(_tO);
			//_tO = setTimeout(dispatch, 100, _discoItems.getItemByID(iq.from.bareJID) as DiscoItemModel );
		}
	}
}