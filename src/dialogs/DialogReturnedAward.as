package dialogs
{
	import utils.FieldUtils;

	public class DialogReturnedAward extends DialogInfo
	{
		public function DialogReturnedAward(award:int):void
		{
			super(gls("Бонус"), gls("Друзья, которых ты позвал в игру,\nсобрали для тебя {0} #Ac и {1} #Ex", award, award * 10));

			var replaces:Array = [
				{'replaceString': "#Ac", 'imageClass': ImageIconNut, 'scaleX': 0.8, 'scaleY': 0.8, 'shiftX': -15, 'shiftY': -12, 'isHtml': true},
				{'replaceString': "#Ex", 'imageClass': ImageIconExp, 'scaleX': 0.8, 'scaleY': 0.8, 'shiftX': -11, 'shiftY': -13, 'isHtml': true}
			];

			FieldUtils.multiReplaceSign(this.content, replaces);
		}
	}
}