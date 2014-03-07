/**
 * 赢了游戏
 */
package code
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import code.GameModel;
	
	public class GameWin extends MovieClip
	{
		//字体
		private var txtWinGameTop:TextField;	//游戏排名
		private var txtWinGameTime:TextField;	//游戏时间
		private var gs:Object;					//游戏数据
		
		public function GameWin()
		{
			this.x = 500;
			this.y = 225;
			this.scaleX = 0.5;
			this.scaleY = 0.5;
			addTxt();
			addEvent();
		}
		
		/**
		 * 删除实例
		 */
		public function dispose(){
			remvoeEvent();
			parent.removeChild(this);
		}
		
		/**
		 * 添加事件
		 */
		private function addEvent(){
			//分享
			btn_share_sina.addEventListener(MouseEvent.CLICK,shareSina);
			btn_share_qq.addEventListener(MouseEvent.CLICK,shareQq);
			btn_share_qzone.addEventListener(MouseEvent.CLICK,shareQzone);
		};
		
		/**
		 * 移除事件
		 */
		private function remvoeEvent(){
			btn_share_sina.removeEventListener(MouseEvent.CLICK,shareSina);
			btn_share_qq.removeEventListener(MouseEvent.CLICK,shareQq);
			btn_share_qzone.removeEventListener(MouseEvent.CLICK,shareQzone);
		}
		
		/**
		 * 分享到新浪微博
		 */
		private function shareSina(event:MouseEvent){
			var url:String = Utils.shareWeiBo("sina");
			Utils.goUrl(url);
		};
		/**
		 * 分享到QQ微博
		 */
		private function shareQq(event:MouseEvent){
			var url:String = Utils.shareWeiBo("qq");
			Utils.goUrl(url);
		};
		
		/**
		 * 分享到QQ空间
		 */
		private function shareQzone(event:MouseEvent){
			var url:String = Utils.shareWeiBo("qzone");
			Utils.goUrl(url);
		};
		
		
		
		/**
		 * 添加文本
		 */
		private function addTxt(){
			gs = GameModel.getInstance().gameSocre;
			//字体初始化
			txtWinGameTop = new TextField();
			txtWinGameTop.x = 4;
			txtWinGameTop.y = -29;
			txtWinGameTop.width = 300;
			txtWinGameTop.height = 50;
			txtWinGameTop.htmlText="<FONT FACE=\"微软雅黑\" SIZE=\"22\" COLOR=\"#FFFFFF\"><B><I>击败了<FONT SIZE=\"24\" COLOR=\"#FAEF0C\">  " + gs.rank + "% </FONT>的玩家</I></B>";
			
			txtWinGameTime = new TextField();
			txtWinGameTime.x = 4;
			txtWinGameTime.y = 6;
			txtWinGameTime.width = 150;
			txtWinGameTime.height = 50;
			txtWinGameTime.htmlText="<FONT FACE=\"微软雅黑\" SIZE=\"22\" COLOR=\"#FFFFFF\"><B><I>" + gs.second + "秒</I></B>"; 
			
			addChild(txtWinGameTop);
			addChild(txtWinGameTime);
		}
		
	}
}