package code
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class GameLost extends MovieClip
	{
		public function GameLost()
		{
			this.x = 500;
			this.y = 225;
			this.scaleX = 0.5;
			this.scaleY = 0.5;
			
			addEvent();
		}
		
		public function dispose(){
			removeEvent();
			parent.removeChild(this);
		}
		
		private function addEvent(){
			btn_goto_use.addEventListener(MouseEvent.CLICK,gotoUse);
		}
		
		private function gotoUse(event:MouseEvent){
			var url:String = Data.YX_SEPT_URL_2;
			Utils.goUrl(url);
		};
		
		private function removeEvent(){
			btn_goto_use.removeEventListener(MouseEvent.CLICK,gotoUse);
		}
	}
}