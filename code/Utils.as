package code
{
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Security;
	import code.GameModel;

	public class Utils
	{
		Security.allowDomain('*');
		
		
		/**
		 * type 分享类型
		 * obj 分享数据  标题 内容 等
		 */
		public static function shareWeiBo(type:String) : String {
			var obj:Object = {
				shareUrl : Data.YX_HOME_URL_PLAY,
				shareTitle:Data.SHARE_TITLE,
				shareCont :Data.shareContent(),
				shareSummary:Data.SHARE_SUMMARY,
				sharePic : Data.SHARE_IMG,
				shareAll:Data.SHARE_TITLE + Data.shareContent() + Data.SHARE_SUMMARY
			};
			trace(obj.shareUrl,"URL")
			var link:String;
			if(type == "qq"){
					link = 'http://v.t.qq.com/share/share.php?title='+obj.shareAll+'&pic='+obj.sharePic+'&url='+obj.shareUrl;
			}else if(type == "sina"){
				link = 'http://v.t.sina.com.cn/share/share.php?title='+obj.shareAll+'&pic='+obj.sharePic+'&url='+obj.shareUrl;
			}else if(type == "qzone"){
				link = 'http://sns.qzone.qq.com/cgi-bin/qzshare/cgi_qzshare_onekey?title='+obj.shareTitle+'&desc='+obj.shareCont+'&summary='+obj.shareSummary+'&pics='+obj.sharePic+'&url='+obj.shareUrl;
			}
			return link;
		}
		
		
		/**
		 * 设置链接
		 */
		public static function goUrl(_url : String,target:String = "_blank") : void {
			var request : URLRequest = new URLRequest(_url);
			navigateToURL(request, target);
		}
		
	}
}