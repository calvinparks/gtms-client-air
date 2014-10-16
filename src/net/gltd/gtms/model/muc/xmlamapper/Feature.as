package net.gltd.gtms.model.muc.xmlamapper
{
	
	[XmlMapping(elementName="feature")]
	public dynamic class Feature 
	{
		[Attribute("var")]
		public var feature:String;
		
		public function Feature()
		{

		}
	}
}