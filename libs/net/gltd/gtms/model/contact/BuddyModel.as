package net.gltd.gtms.model.contact
{
	import net.gltd.gtms.GUI.contextMenu.ContextMenuItem;
	import net.gltd.gtms.model.im.AvatarModel;
	
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	
	import mx.collections.ArrayCollection;
	

	public dynamic class BuddyModel extends EventDispatcher
	{
		
		
		private				var			_onPhone				:uint = 0,
										_icoPath				:String,
										_ico					:Class,
										_camera					:Class,
										_mark					:Boolean = false,
										_menuOptions			:Vector.<ContextMenuItem> = new Vector.<ContextMenuItem>(),
										_renderMenuItemsFunction:Function; // Return Vector.<ContextMenuItem> with contextMenu Items
	
		protected			var			_id						:String,
										_kind					:String,
										_groupKind				:String;								
									
									
		public 				var		   	groups					:ArrayCollection,
										onList					:Boolean = false,
										clickFunction			:Function,
										icoClickFunction		:Function,
										
										creationDate			:Number,
										
										sortKey					:Number = 0,
										groupName				:String = "";
		
		[Bindable]						
		public				var			avatar					:AvatarModel =  new AvatarModel();							
									
		
								
		private				var			_nickname			:String,
										_searchString			:String = "";
			

		
		public function BuddyModel(id:String,grps:Array,kind:String,groupKind:String)
		{
			this._id 				= id;
			this._kind 				= kind;
			this.groups				= new ArrayCollection(grps as Array);
			this._groupKind			= groupKind;
			
			creationDate = getTimer();
	
			
		}
		public function kill():void {
			nickname = null;
			ico = null;
			_menuOptions = null;
			_id = null;
			_groupKind = null;
			if (groups)groups.removeAll();
			groups = null;
			if (avatar)avatar.kill();
			avatar = null;
			_searchString = null;
			
		}
		
		[Bindable]
		public function get nickname():String {
			return _nickname
		}
		public function set nickname(s:String):void {
			_nickname = s;
		}
		
		[Bindable]
		public function get displayName():String {
			return nickname;
		}
		
		public function set displayName(s:String):void {
			 nickname = s;
		}
		
		
		public function get searchScope():String {
			var tmp:String =  nickname + _searchString;
			try {
				for (var i:uint = 0; i<groups.source.length;i++){
					tmp+=groups.source[i];
				}
			}catch (error:Error){}
			
			return tmp;
		}
		public function addSearchString(v:String):void {
			if (_searchString == null)_searchString = "";
			_searchString+=(" "+v);
		}
		public function get searchString():String {
			return _searchString
		}
		public function set searchString(s:String):void {
			 _searchString = s;
		}
		
		
		public function set onPhone(val:uint):void {
			_onPhone = val;
			
		}
		public function get onPhone():uint {
			return _onPhone
		}
		
		public function get kind():String {
			return _kind;
		}
		public function get groupKind():String {
			return _groupKind;
		}
		public function get id():String {
			return _id;
		}
		
		public function setMenuItem(item:ContextMenuItem):void {
			_menuOptions.push(item);
		}
		public function get menuOptions():Vector.<ContextMenuItem> {
			return _menuOptions;
		}
		
	
		
		[Bindable]
		public function get ico():Class {
			return _ico;
		}
		public function set ico(s:Class):void {
			_ico = s;
		}
		[Bindable]
		public function get camera():Class {
			return _camera;
		}
		public function set camera(s:Class):void {
			_camera = s;
		}
		
		[Bindable]
		public function get mark():Boolean {
			return _mark;
		}
		public function set mark(s:Boolean):void {
			_mark = s;
		}
		
		public function set icoPath (url:String):void  {
			_icoPath = url;
		}
		[Bindable]
		public function get icoPath ():String {
			return _icoPath;
		}
		
		public function set renderMenuItemsFunction(f:Function):void {
			_renderMenuItemsFunction = f;
		}
		public function get renderMenuItemsFunction():Function {
			return _renderMenuItemsFunction;
			
		}
		
	}
}