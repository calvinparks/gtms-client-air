/*
** GroupModel.as , package net.gltd.gtms.model.im **  
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
	import net.gltd.gtms.utils.FilterArrayCollection;
	
	import mx.core.ClassFactory;
	
	import spark.collections.Sort;
	import spark.collections.SortField;

	public class GroupModel
	{
		
		public		var		kind					:String,
							displayOnList			:Boolean = true,
							isOnList				:Boolean,
							clickFunction			:Function,
							renderMenuItemsFunction	:Function,
							isClosed				:Boolean = false,
							id						:String,
							noneExist				:Boolean = false,
							visible					:Boolean = true;
							
						

		[Bindable]		
		public		var		itemCollection		:FilterArrayCollection;
							
		[Bindable][ArrayElementType("Function")] 
		private 	var		_filterFunctions	:Array = [];
		
		[Bindable][ArrayElementType("SortField")] 
		private		var		_sortFields			:Array = [];
		
		
		private		var		_length				:uint = 0,
							_groupName			:String,
							_groupKind			:String,
							_itemRenderer		:ClassFactory,
							_virtual			:Boolean,
							_sortKey			:Number = 0;
								
		
		public function GroupModel(name:String, kind:String, itemRenderer:ClassFactory, filters:Array, virtual:Boolean)
		{
			this.groupName = name;
			this.groupKind = kind;
			this.itemRenderer = itemRenderer;
			this.virtual = virtual;
			this.itemCollection = new FilterArrayCollection();
			if (filters!=null)_filterFunctions = filters;
			this.itemCollection.filterFunction = getFilters;

			var sort:Sort = new Sort();
			sort.fields = _sortFields;
			this.itemCollection.sort = sort;
			
			id = name+"_"+kind;
			
		}
		public function kill():void {
			itemCollection.filterFunction = null;
			itemCollection.sort = null;
			_sortFields = null;
			_filterFunctions = null;
			itemCollection.removeAll();
			itemCollection = null;
		}
		public function setItem(item:BuddyModel):void {
			itemCollection.addItem(item);
			length = itemCollection.length;
			itemCollection.refresh();
		}
		public function set sortField(sf:SortField):void {
			_sortFields.push(sf);
		}
		public function set filterFunction(f:Function):void {
			_filterFunctions.push(f);
		}
		
		protected function getFilters(obj:BuddyModel):Boolean {
			var b:Boolean = true;
			for (var i:uint = 0; i < _filterFunctions.length;i++){
				b = b && _filterFunctions[i](obj);
			}
			return b;
		}
		
		public function set length(l:uint):void {
			_length = l;
		}
		[Bindable]
		public function get length():uint {
			return _length;
		}
		public function set groupName(gn:String):void {
			_groupName = gn
		}		
		[Bindable]
		public function get groupName():String {
			return _groupName;
		}
		public function set nickname(gn:String):void {
			_groupName = gn
		}		
		[Bindable]
		public function get nickname():String {
			return _groupName;
		}
		
		
		public function set groupKind(gk:String):void {
			_groupKind = gk
		}		
		[Bindable]
		public function get groupKind():String {
			return _groupKind;
		}
		private function set itemRenderer(ir:ClassFactory):void {
			_itemRenderer = ir;
		}
		[Bindable]
		public function get itemRenderer():ClassFactory {
			return _itemRenderer;
		}
		
		public function set virtual(v:Boolean):void {
			_virtual = v;
		}
		public function get virtual():Boolean {
			return _virtual;
		}
		public function get searchScope():String {
			return groupName+groupKind;	 
		}
		
		public function get buddyKind():String {
			try {
				return itemCollection.source[0].kind;
			}catch (error:Error){
				
			}
			return null;
		}
		
		public function set sortKey(i:int):void {
			if (isNaN(i))return
			_sortKey = i;
		}
		public function get sortKey():int {
			return _sortKey;
		}
		
		//public function set
	}
}