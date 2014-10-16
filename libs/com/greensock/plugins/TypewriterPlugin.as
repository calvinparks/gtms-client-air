/**
   VERSION: 1.2
   DATE: 3/27/2010
   ACTIONSCRIPT VERSION: 3.0
   @author Marco Di Giuseppe, marco [at] designmarco [dot] com
   @link http://designmarco.com
 */
package com.greensock.plugins
{
	import flash.text.TextField;
	import com.greensock.TweenLite;
	/**
	   TypewriterPlugin tweens the characters of a Textfield simulating a typing effect.

	   @usage
	   import com.greensock.TweenLite;
	   import com.greensock.plugins.TweenPlugin;
	   import com.greensock.plugins.TypewriterPlugin;

	   TweenPlugin.activate([TypewriterPlugin]); //activation is permanent in the SWF, so this line only needs to be run once.
	   TweenLite.to(textField, 0.5, {typewriter:"Lorem Ipsum"});

	   Greensock Tweening Platform
	   @author Jack Doyle, jack@greensock.com
	   Copyright 2010, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html
	   or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
	 */
	public class TypewriterPlugin extends TweenPlugin
	{
		public static const API:Number = 1.0;
		protected var target:TextField;
		protected var newText:String;
		protected var newLength:int;
		protected var oldText:String;
		protected var oldLength:int;

		public function TypewriterPlugin()
		{
			super();
			this.propName = "typewriter";
			this.overwriteProps = [];
		}

		override public function onInitTween(target:Object, value:*, tween:TweenLite):Boolean
		{
			if (!(target is TextField)) return false;

			this.target = target as TextField;

			oldText = target.text;
			oldLength = oldText.length;

			newText = String(value);
			newLength = newText.length;

			return true;
		}

		override public function set changeFactor(n:Number):void
		{
			var valueA:Number = oldLength + (-oldLength * n);
			var valueB:Number = oldLength + ((newLength - oldLength) * n);
			target.text = newText.substr(0, int(valueB - valueA + 0.5)) + oldText.substr(0, int(valueA + 0.5));
		}
	}
}