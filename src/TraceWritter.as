////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package 
{
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import mx.core.FlexGlobals;
	import mx.core.mx_internal;
	import mx.logging.targets.LineFormattedTarget;
	
	use namespace mx_internal;
	
	/**
	 *  Provides a logger target that uses the global <code>trace()</code> method to output log messages.
	 *  
	 *  <p>To view <code>trace()</code> method output, you must be running the 
	 *  debugger version of Flash Player or AIR Debug Launcher.</p>
	 *  
	 *  <p>The debugger version of Flash Player and AIR Debug Launcher send output from the <code>trace()</code> method 
	 *  to the flashlog.txt file. The default location of this file is the same directory as 
	 *  the mm.cfg file. You can customize the location of this file by using the <code>TraceOutputFileName</code> 
	 *  property in the mm.cfg file. You must also set <code>TraceOutputFileEnable</code> to 1 in your mm.cfg file.</p>
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class TraceWritter extends LineFormattedTarget
	{
		//include "../../core/Version.as";
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *
		 *  <p>Constructs an instance of a logger target that will send
		 *  the log data to the global <code>trace()</code> method.
		 *  All output will be directed to flashlog.txt by default.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		private var fileStream:FileStream;
		private var bytes:ByteArray;
		public function TraceWritter()
		{
			var file:File = File.documentsDirectory.resolvePath(FlexGlobals.topLevelApplication.applicationID+".log");
			if (file.exists==false){
			}
			bytes = new ByteArray();
			fileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);  
			bytes.writeUTF("\n\n new run "+new Date().toString()+"\n");
			//fileStream.writeUTF("\n new run "+new Date().toString()+"\n");
			fileStream.writeBytes(bytes);
			fileStream.close();
			
			fileStream.open(file, FileMode.UPDATE);  
			
			
		}
		public function closeFile():void {
			fileStream.close(); 
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  This method outputs the specified message directly to 
		 *  <code>trace()</code>.
		 *  All output will be directed to flashlog.txt by default.
		 *
		 *  @param message String containing preprocessed log message which may
		 *  include time, date, category, etc. based on property settings,
		 *  such as <code>includeDate</code>, <code>includeCategory</code>, etc.
		 */
		override mx_internal function internalLog(message:String):void
		{
			trace(message);
			try {
				bytes.writeUTF(message+"\n");
				fileStream.writeBytes(bytes);
				bytes.clear();
			}catch (error:Error){
				
			}
		}
		
	}
	
}
