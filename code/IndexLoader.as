package code
{
	
    import flash.display.*;
    import flash.events.*;
    
	import com.greensock.*;
import com.greensock.loading.*;
import com.greensock.events.LoaderEvent;
import com.greensock.loading.display.*;
import flash.display.MovieClip;
   

    public class IndexLoader extends Sprite
    {
        private var queue:LoaderMax;


        public function IndexLoader()
        {
            if (this.stage)
            {
                this.addedToStageHandler();
            }
            else
            {
                this.addEventListener(Event.ADDED_TO_STAGE, this.addedToStageHandler);
            }
            return;
        }// end function

        protected function addedToStageHandler(event:Event = null)
        {
            this.removeEventListener(Event.ADDED_TO_STAGE, this.addedToStageHandler);
            this.init();
        }// end function

        private function init() : void
        {
            queue = new LoaderMax({name:"mainQueue", 
											onProgress:onProgress, 
											onComplete:onComplete, 
											onError:onError}); 
            queue.append( new SWFLoader('bg.swf', {name:"bg"}) );
			queue.append( new SWFLoader('t.swf', {container : this,name:"t1"}) );
			LoaderMax.prioritize("bg");
			queue.load();
            return;
        }// end function
		
		private function onError(e:LoaderEvent):void
        {
            trace('MySWF::onError');
            trace(e.toString());
        }
         
        private function onProgress(e:LoaderEvent):void
        {
            //trace('MySWF::onProgress');
            //trace(e.toString());
        }
         
        private function onComplete(e:LoaderEvent):void
        {
            trace('MySWF::onComplete');
            trace(e.toString());
			var image:MovieClip = LoaderMax.getContent("t1").rawContent;
    		image.x = 1;
			image.aa();
			//image.mc2.x = 300;
			//image.get
			trace(image);
    		trace(e.target + " is complete!");
        }

        

    }
}
