/*
** ContactKind.as , package net.gltd.gtms.model.im **  
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
package net.gltd.gtms.model.contact.singl
{
	import net.gltd.gtms.model.contact.GroupModel;
	
	import mx.core.ClassFactory;

	public class groupHolder
	{
		public		static  	var 			dH					:groupHolder;
		
		private		static		var				_groupKind			:Vector.<String>;
		
		private					var				_groups				:Vector.<GroupModel>,
												_groupsKeys			:Object;
		
		
		public static function getInstance(): groupHolder {
			if (dH == null) {
				dH = new groupHolder(arguments.callee);
			}
			return dH;
			
		}
		public static function destroy():void {
			dH = null;
		}
		public function groupHolder(caller:Function=null) {
			if (caller != groupHolder.getInstance) {
				throw new Error("SINGELTON use -> getInstance()");
			}else {
				_groupKind			 = new Vector.<String>();
				_groups				 = new Vector.<GroupModel>(),
				_groupsKeys			 = {};
			}
			if (groupHolder.dH != null) {
				throw new Error("Error");
			}
		}	
		public function kill():void {
			for (var i:uint = 0; i<_groups.length;i++){
				_groups[i].kill()
			}
			_groupKind = null;
			_groups = null;
			_groupsKeys = null;
		}
	
		public static function get GROUP_KIND():Vector.<String> {
			return _groupKind;
		}
		
		public function set groupKind(_name:String):void {
			_groupKind.push(_name);
		} 
		public function setGroup (name:String, kind:String,itemRenderer:ClassFactory=null,filters:Array=null,virtual:Boolean=false) : int {
			if (_groupsKeys[name+kind] != undefined) return -1;
	
			var grIndex:uint = 	_groups.push(  new GroupModel (name, kind, itemRenderer, filters, virtual) ) - 1;
			_groupsKeys[name+kind] = grIndex;
			return grIndex;
		}
		
		public function get groups():Vector.<GroupModel> {
			return _groups;
		}
		public function getGroup(id:*):GroupModel {
			if ( isNaN(id) ) return _groups[_groupsKeys[id]];
			return _groups[id]
		}
	
		
		
	}
}