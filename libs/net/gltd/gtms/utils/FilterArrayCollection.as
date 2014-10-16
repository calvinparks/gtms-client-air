package net.gltd.gtms.utils
{
	import mx.collections.ArrayCollection;

	public class FilterArrayCollection extends ArrayCollection
	{
		public var keys:Object = {};
		public	var	ignoreCaseSensitivity:Boolean;
		private var keyName:String;
		
		public function FilterArrayCollection(source:Array=null,keyName:String="id")
		{
			keys = {};
			if (source==null)source =[];
			this.keyName = keyName;
			//var filteredArr:Array = source.filter(removedDuplicates);
			super(source);
		}
		public function removeByID(id:String):int {	
			for(var i:uint = 0; i < this.length; i++){
				if (getItemAt(i)[keyName] == id){
					removeItemAt(i);
					return i;
				}
			}
			try {
				if (ignoreCaseSensitivity){
					for(i = 0; i < this.length; i++){
						if (getItemAt(i)[keyName].toString().toLowerCase() == id.toLowerCase()){
							removeItemAt(i);
							return i
						}
					}
				}
			}catch (error:Error){}
			return -1
		}
		public function getItemIndexByID(id:String):int {
			
			for(var i:uint = 0; i < this.length; i++){
				if (getItemAt(i)[keyName] == id){
					return i
				}
			}
			try {
				if (ignoreCaseSensitivity){
					for(i = 0; i < this.length; i++){
						if (getItemAt(i)[keyName].toString().toLowerCase() == id.toLowerCase()){
							return i
						}
					}
				}
			}catch (error:Error){}
			return -1
		}
		public function getIndexByKey(key:String,searchValue:String):int {
			
			for(var i:uint = 0; i < this.length; i++){
					try {
					if (getItemAt(i)[key] == searchValue){
						return  i;
					}
				}catch (error:Error){
					continue;
				}
			}
			try {
				if (ignoreCaseSensitivity){
					for(i = 0; i < this.length; i++){
						if (getItemAt(i)[key].toString().toLowerCase() == searchValue.toLowerCase()){
							return  i;
						}
					}
				}
			}catch (error:Error){}
			return -1
		}
		public function getItemByID(id:String, ignoreCaseSensitivity:Boolean=false):Object {
			for(var i:uint = 0; i < this.length; i++){
				if (getItemAt(i)[keyName] == id){
					return getItemAt(i)
				}
			}
			try {
				if (this.ignoreCaseSensitivity || ignoreCaseSensitivity){
					for(i = 0; i < this.length; i++){
						if (getItemAt(i)[keyName].toString().toLowerCase() == id.toLowerCase()){
							return getItemAt(i)
						}
					}
				}
			}catch (error:Error){}
			return null;
		}
		
 
		public function hasChlid(item:Object):Boolean {
			if (keys.hasOwnProperty(item[keyName])) {
				return true;
			} else {
				//keys[item[keyName]] = true;
				return false;
			}
		}
		
		private function removedDuplicates(item:Object, idx:uint, arr:Array):Boolean {
			if (keys.hasOwnProperty(item[keyName])) {
				return false;
			} else {
				keys[item[keyName]] = true;
				return true;
			}
		}
		public override function addItem(item:Object):void
		{	
			if (keys[item[keyName]] == undefined){
				keys[item[keyName]] = true;
				addItemAt(item, length);
			}
		}
		
		public override function removeAll():void
		{
			
			super.removeAll();
			keys = {};
		}
		public override function removeItemAt(index:int):Object
		{
			try {
				delete keys[super.getItemAt(index)[keyName]]
				localIndex[index][keyName] = undefined;
				delete [localIndex[index][keyName]]
			}catch (e:Error){
				
			}
			return super.removeItemAt(index)
		}

	}
}