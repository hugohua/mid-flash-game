package code
{
	import code.GameModel;
	public class Data
	{
		
		public static const YX_HOME_URL:String = encodeURIComponent("http://www.yixun.com/?YTAG=10100&game=true");
		public static const YX_HOME_URL_PLAY:String = encodeURIComponent("http://www.yixun.com/?YTAG=10100&game=true");
		public static const YX_LOGIN_URL:String = "https://base.yixun.com/login.html";
		public static const YX_COUPON_URL:String = "http://base.yixun.com/mycoupon.html";
		public static const YX_SEPT_URL:String = "http://u.yixun.com/sept?YTAG=0.1940100001300000";
		public static const YX_SEPT_URL_2:String = "http://u.yixun.com/sept?YTAG=0.1940100001300000";

		public static const YX_LOTTERY_URL: String = "http://event.yixun.com/xml.php?rand=&mod=lotteryge&act=order&oder_lottery=0&sn=12925&order_id=0";
//		public static const YX_LOTTERY_URL:String = "lottery.xml";
		
		public static const LOTTERY_EMPTY:String = "诶哟喂~是空的！";
		public static const LOTTERY_SEPT:String = "听说“金九狂欢月”也有惊喜，快去看看！";
		
		public static const LOTTERY_5:String = "您获得5元优惠券！";
		public static const LOTTERY_RULE_5:String = "使用规则：全场购物满50减5元，需要在9月30号前使用，过期无效。";
		
		public static const LOTTERY_10:String = "您获得10元优惠券！";
		public static const LOTTERY_RULE_10:String = "使用规则：全场购物满100减10元，需要在9月30号前使用，过期无效。";
		
		public static const LOTTERY_ERROR:String = "抽奖失败!";
		public static const LOTTERY_NO_LOGIN:String = "您尚未登录，请登录后再抽奖！";
		
		public static const LOTTERY_EXCEED:String = "每人每天只能抽奖3次，您已超过抽奖次数上限！";
		public static const LOTTERY_SERVER_ERROR:String = "服务器繁忙，请稍后再试！";
		
		public static const SHARE_IMG:String = "http://img3.icson.com/template/2013/09/16/137929432028553700_a_4.jpg";
		public static const SHARE_TITLE:String = encodeURIComponent("#保卫月亮赢10元优惠券# ");
		
		public static const SHARE_SUMMARY:String = encodeURIComponent("（我会和你说，参加即有机会获得10元优惠券吗！）");
		
		public static function shareContent():String{
			var gameScore:Object = GameModel.getInstance().gameSocre;
			var cont:String;
			if(gameScore){
				cont = encodeURIComponent("中秋怎能没有月亮，快和我一起参加“守月行动”！我花了"+ gameScore.second +"秒的时间，超越了"+ gameScore.rank +"%的玩家，你也来挑战下？！");
			}else{
				cont = encodeURIComponent("中秋怎能没有月亮，快和我一起参加“守月行动”！，你也来挑战下？！");
			}
			return cont;
		}
	}
}