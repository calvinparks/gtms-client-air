/*
** IMBuddyModel.as , package net.gltd.gtms.model.contact **  
* 
*	 Globility Limited
* 
*	 Copyright 2012. All rights reserved. 
* 
*	 Author: Piotr Kownacki ( pinczo@pinczo.net )
*	 pinczo 
*	 communified_v3.2 
*	 Created: Jun 14, 2012 
*
*
*/ 
package net.gltd.gtms.model.contact
{
	
	import net.gltd.gtms.controller.im.ShowStatusManager;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.igniterealtime.xiff.data.im.RosterItemVO;
	import org.igniterealtime.xiff.events.PropertyChangeEvent;
	import org.igniterealtime.xiff.events.VCardEvent;
	import org.igniterealtime.xiff.vcard.VCard;

	[Event(name="change", type="org.igniterealtime.xiff.events.PropertyChangeEvent")]
	public dynamic class IMBuddyModel extends BuddyModel
	{
		
		public 	static	const	GROUP_KIND			:String = "im_group",
								BUDDY_KIND			:String = "im_buddy";
		
		private			var		_roster				:RosterItemVO,
								_hasCamera			:Boolean = false,
								_vCard				:VCard,
								_composing			:Boolean = false,
								_timer				:Timer = new Timer(800,2),
								_show				:Class,
								_statusMsg			:String,
								_archiveList		:Array,
								_archiveGrList		:Array;
		public			var		displayOnList		:Boolean = true;
		
		public function IMBuddyModel(id:String, r:RosterItemVO, groups:Array)
		{
			super(id, groups,BUDDY_KIND,GROUP_KIND);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,onTick,false,0,true)
			roster = r;
		}
		public override function kill():void {
			if (_timer){
				_timer.removeEventListener(TimerEvent.TIMER_COMPLETE,onTick);
				if (_timer.running)_timer.stop();
			}
			_roster.removeEventListener(PropertyChangeEvent.CHANGE,onRosterChange);
			_vCard.removeEventListener(VCardEvent.LOADED,onVcardLoaded);
			_timer = null;
			_vCard = null;
			_roster = null;
			super.kill();
		}
		
		
		[Bindable]
		public function get roster ():RosterItemVO {
			return _roster;
		}
		[Bindable]
		public function get vCard ():VCard {
			return _vCard;
		}
		public function set roster (r:RosterItemVO):void {
			super.nickname = r.nickname;
			super.addSearchString(r.jid.node);
			show = ShowStatusManager.getShowIco(r);
			status = r.status;
			_roster = r;
			_roster.addEventListener(PropertyChangeEvent.CHANGE,onRosterChange,false,0,true);
		}
		
		public function onRosterChange(event:PropertyChangeEvent):void{
			if (event.name == "status" || event.name == "show" || event.name == "online") 
			show = ShowStatusManager.getShowIco(event.currentTarget as RosterItemVO);
			status = (event.currentTarget as RosterItemVO).status;
			dispatchEvent(event.clone())
		}
		private function onVcardLoaded(event:VCardEvent):void {
			
			try {
				if (event.vcard.photo != null){
					if (event.vcard.photo.bytes==null) return;
					
					avatar.add( event.vcard.photo.bytes );
				}
			}catch (error:Error){
				trace (error.getStackTrace());
			}
		}
		public function set vCard (v:VCard):void {
			_vCard = v;
			_vCard.addEventListener(VCardEvent.LOADED,onVcardLoaded);
			
		}
		public function set hasCamera (b:Boolean):void {
			_hasCamera = b;
			
		}
		public function get hasCamera ():Boolean {
			return _hasCamera;
		}
		
		[Bindable (event="showChanged")]
		public function get show ():* {
			if (roster.pending==true){
				status = "Pending..."
				return null;
			}
			if (super.mark) return ShowStatusManager.getIco("immessage");
			return _show;
		}
		
		public function set show (b:*):void {
			_show = b;
			dispatchEvent(new Event("showChanged"));
		}
		
		[Bindable (event="showChanged")]
		public function get rosterShow ():* {
			return _show;
		}
		public function set rosterShow (nic:*):void {
			dispatchEvent(new Event("showChanged"));
		}
		
		[Bindable]
		public function get status ():String {
			return _statusMsg;
		}
		public function set status (s:String):void {
			_statusMsg = s;
		}
		
		
		public function set composing (b:Boolean):void {
			_composing = b;
			show= _show;
			dispatchEvent(new Event("composingChanged"));
		}
		[Bindable (event="composingChanged")]
		public function get composing ():Boolean {
			return _composing;
		}
		
		
		public function setComposingTimer():void {
			if (_timer.running){
				_timer.stop();
				_timer.reset();
				
			}
			_timer.start()
		}
		public override function set mark(s:Boolean):void {
			super.mark = s;
			show = _show;
			
		}
		private function onTick(event:TimerEvent):void {
			composing = false;
		} 
		public function get archiveGrList():Array {
			return _archiveGrList;
		}
		public function set archiveGrList(a:Array):void {
			_archiveGrList = a;
		}
		public function get archiveList():Array {
			return _archiveList;
		}
		public function set archiveList(a:Array):void {
			_archiveList = a;
		}
		
		
		public function setDifferentKind(s:String):void {
			_kind = s;
		}
		public function setDifferentGroupKind(s:String):void {
			_groupKind = s;
		}
	}
}