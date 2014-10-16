package net.gltd.gtms.events
{
        import flash.events.Event;
        
        import org.igniterealtime.xiff.data.IQ;
 

        public class FileTransferEvent extends Event
        {
                public static const OUTGOING_FEATURE:String = "outgoingFeature";
                public static const OUTGOING_OPEN:String = "outgoingOpen";
                public static const OUTGOING_CLOSE:String = "outgoingClose";
 
                public static const INCOMING_FEATURE:String = "incomingFeature";
                public static const INCOMING_OPEN:String = "incomingOpen";
                public static const INCOMING_CLOSE:String = "incomingClose";
 
                 /**
                  * Extensions that might be related to the event type.
                  * FeatureNegotiationExtension, FileTransferExtension
                  */
                public var extensions:Array;
 
                 /**
                  * The original IQ that contained the extension that might have triggered this event.
                  */
                public var iq:IQ;
 
                 /**
                  *
                  * @param       type
                  * @param       bubbles
                  * @param       cancelable
                  */
                public function FileTransferEvent( type:String, bubbles:Boolean = false, cancelable:Boolean = false )
                {
                        super( type, bubbles, cancelable );
                }
 
                override public function clone():Event
                {
                        var event:FileTransferEvent = new FileTransferEvent( type, bubbles, cancelable );
                        return event;
                }
 
                override public function toString():String
                {
                        return '[FileTransferEvent type="' + type + '" bubbles=' + bubbles + ' cancelable=' +
                                cancelable + ' eventPhase=' + eventPhase + ']';
                }
        }
} 