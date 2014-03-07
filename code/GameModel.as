package code
{
	import flash.net.SharedObject;
	import code.LocalSO;
	
	public class GameModel
	{
		private var score:Object;
		private static var _instance:GameModel;
		private var mySo:SharedObject;
		
		public static function getInstance():GameModel {
			return _instance ? _instance : (new GameModel());
		}
		
		public function GameModel()
		{
			if(!_instance)
				_instance=this;
			else 
				throw new Error("GameModel is a singale class")
		}
		
		/**
		 * 获取游戏时间及排名
		 */
		public function get gameSocre():Object{
			if(score){
				return score;
			}else{
				var lso:LocalSO=LocalSO.getInstance();
				lso.getsharedObject("game");
				trace(lso.getAt("gameScore")) ; // 如果flush成功则输出"value"
				return lso.getAt("gameScore") as  Object;
			}
		}
		
		/**
		 * 设置游戏时间及排名
		 */
		public function set gameSocre(obj:Object):void{
			score = obj;
			var lso:LocalSO=LocalSO.getInstance();
			lso.getsharedObject("game");
			lso.setKey("gameScore",score);
			trace(lso.flush());
		}
	}
}