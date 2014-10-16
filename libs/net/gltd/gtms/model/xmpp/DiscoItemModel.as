/*
** DiscoItemModel.as , package net.gltd.gtms.model.xmpp **  
* 
*	 Globility Limited
* 
*	 Copyright 2012. All rights reserved. 
* 
*	 Author: Piotr Kownacki ( pinczo@pinczo.net )
*	 pinczo 
*	 communified_v3.2 
*	 Created: Jun 20, 2012 
*
*
*/ 
package net.gltd.gtms.model.xmpp
{
	import mx.collections.ArrayCollection;
	
	import org.igniterealtime.xiff.core.EscapedJID;

	public class DiscoItemModel
	{
		private			var			_id				:String,
									_name			:String,
									_label			:String,
									_jid			:EscapedJID,
									_identities		:ArrayCollection = new ArrayCollection([]),
									_profileObject	:Object,
									_category		:String = "";
									
									
		[Bindable]							
		public			var			enabled			:Boolean = true;
		public function DiscoItemModel(id:String,name:String,jid:EscapedJID)
		{
			_id		= id;
			_name	= name;
			_jid	= jid;
			try {
				var a:Array = name.toString().split(" ");
				var l:String = ""
				for (var i:uint = 0; i<a.length; i++){
					if (i > 0)l +=" "
					var tmp:String = a[i].toString();
					l += tmp.slice(0,1).toString().toUpperCase() + tmp.slice(1,tmp.length).toString().toLowerCase();
				}
				label = l; 
			}catch (error:Error){
				label =  _id;
			}
			
		}
		
		public function  setIdentity (identity:Object):void {
			_identities.addItem(identity);
			if (identity.category==null)return;
			if (_category.length > 0)_category+=", ";
			_category += identity.category;
			
		}
		public function resetIdentitys():void {
			_identities = new ArrayCollection();
		}
		[Bindable]
		public function get label():String {
			return _label
		}
		public function set label(l:String):void {
			_label = l;
		}
		public function get id():String {
			return _id;
		}
		[Bindable]
		public function get name():String {
			return _name;
		}
		public function set name(n:String):void {
			n = _name;
		}
		
		[Bindable]
		public function get jid():EscapedJID {
			return _jid;
		}
		public function set jid(j:EscapedJID):void {
			 _jid = j;
		}
		[Bindable]
		public function get identitiesCollection():ArrayCollection {
			return _identities;
		}
		public function set identitiesCollection(ac:ArrayCollection):void {
			 _identities = ac;
		}
		
		public function get identities():Array {
			return _identities.source;
		}
		public function get profileObject():Object {
			return _profileObject;
		}
		public function set profileObject(p:Object):void {
			_profileObject = p;
		}
		public function set category(c:String):void {
			_category = c;
		}
		[Bindable]
		public function get category():String {
			return _category;
		}
	}
}