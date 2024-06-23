/*
* ...
* @author SecretFox
*/
import com.GameInterface.Game.CharacterBase;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.GameInterface.UtilsBase;
import com.Utils.Colors;
import com.Utils.Format;
import com.Utils.ID32;
import com.Utils.LDBFormat;
import mx.utils.Delegate;
 
class com.fox.Defragger 
{
	public var m_SwfRoot:MovieClip;
	public var timeout:Number;
	public var m_Inventory:Inventory;
	public var Fragments:Object;
	
	public static function main(swfRoot:MovieClip):Void
	{
		var s_app = new Defragger(swfRoot);
		swfRoot.onLoad = function(){s_app.Load()};
		swfRoot.onUnload = function(){s_app.Unload()};
	}

	public function Defragger(root) {
		m_SwfRoot = root;
		Fragments = {}
		// Fragments[9290325] = 0; // Common cache stuff for debugging
		// Fragments[9290140] = 0; // Common cache stuff for debugging
		// Fragments[9290321] = 0; // Common cache stuff for debugging
		// Fragments[9290319] = 0; // Common cache stuff for debugging
		// Fragments[9271323] = 0; // Common cache stuff for debugging
		// Fragments[9290280] = 0; // Common cache stuff for debugging
		
		Fragments[9455912] = 0; // Elaborate Glyph Fragment
		Fragments[9455913] = 0; // Resplendent Talisman Fragments
	}
	
	public function Load()
	{
		m_Inventory = new Inventory(new ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, CharacterBase.GetClientCharID().GetInstance()));
		if (!CharacterBase.SendLootBoxReply.base)
		{
			var delegate = Delegate.create(this, SendLootBoxReply);
			var f:Function = function()		{
				if ( arguments[0] == true )
				{
					delegate();
				}
				arguments.callee.base.apply(this, arguments);
			};
			f.base = CharacterBase.SendLootBoxReply;
			CharacterBase.SendLootBoxReply = f;
		}
	}
	
	public function Unload()
	{
	}
	
	public function SendLootBoxReply()
	{
		clearTimeout(timeout);
		timeout = setTimeout(Delegate.create(this, StopTracking), 1000);
		GetCurrentFragments();
	}
	
	public function GetCurrentFragments()
	{
		for (var i in Fragments)
		{
			Fragments[i] = 0;
		}
		for (var i = 0; i < m_Inventory.GetMaxItems(); i++)
		{
			var item:InventoryItem = m_Inventory.GetItemAt(i);
			if (item)
			{
				if ( Fragments[item.m_ACGItem.m_TemplateID0] != undefined) {
					Fragments[item.m_ACGItem.m_TemplateID0] += item.m_StackSize;
				}
			}
		}
	}
	
	public function GenerateItemLink(item:InventoryItem)
	{
		var itemLinkArray:Array = [
			item.m_ACGItem.m_TemplateID0,
			item.m_ACGItem.m_TemplateID1,
			item.m_ACGItem.m_TemplateID2,
			item.m_ACGItem.m_Level,
			item.m_ACGItem.m_PrefixLevel,
			item.m_ACGItem.m_SuffixLevel,
			"616e09b0:4dd8af57:3b929b98:cf0d4d11/b290805c:29e627ca:b290805c:29e627ca/b290805c:29e627ca:b290805c:29e627ca'>" // Decrypt key (unused)
		]
		
		var itemArray:Array = [
			"<a style = 'text-decoration:none' href='itemref://",
			itemLinkArray.join("/"),
			"<font color=",
			Colors.ColorToHtml(Colors.GetItemRarityColor(item.m_Rarity)),
			">[<localized category=50200 id=" + item.m_ACGItem.m_TemplateID0 + ">]</font></a>"
		]
		return itemArray.join("");
	}
	
	public function StopTracking():Void 
	{
		var NewCount:Object = {};
		for (var i in Fragments)
		{
			NewCount[i] = 0;
		}
		var InventoryItems:Object = {};
		for (var i = 0; i < m_Inventory.GetMaxItems(); i++)
		{
			var item:InventoryItem = m_Inventory.GetItemAt(i);
			if (item)
			{
				if ( NewCount[item.m_ACGItem.m_TemplateID0] != undefined) {
					NewCount[item.m_ACGItem.m_TemplateID0] += item.m_StackSize;
					InventoryItems[item.m_ACGItem.m_TemplateID0] = item;
				}
			}
		}
		
		for (var i in Fragments)
		{
			if ( Fragments[i] != NewCount[i])
			{
				var diff = NewCount[i] - Fragments[i];
				var item:InventoryItem = InventoryItems[i];
				var itemLink:String = GenerateItemLink(item);
				if ( diff == 1) UtilsBase.PrintChatText(">" + Format.Printf(LDBFormat.LDBGetText(100, 145635597), itemLink), 1073741831);
				else UtilsBase.PrintChatText(">" + Format.Printf(LDBFormat.LDBGetText(100, 4460564), diff, itemLink), 1073741831);
			}
		}
	}
}