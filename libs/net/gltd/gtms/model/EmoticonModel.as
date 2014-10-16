package net.gltd.gtms.model
{
	public class EmoticonModel
	{
		public var name:String;
		public var ico:String;
		public function EmoticonModel(n:String,path:String)
		{
			ico = path;
			name = n;
		}
	}
}