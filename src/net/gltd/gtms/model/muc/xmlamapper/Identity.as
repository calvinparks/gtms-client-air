package net.gltd.gtms.model.muc.xmlamapper
{
	[XmlMapping(elementName="identity")]
	public class Identity
	{
		[Attribute("name")]
		public var name:String;
		
		[Attribute("category")]
		public var category:String;
		
		[Attribute("type")]
		public var type:String;
		
		public function Identity()
		{
		}
	}
}