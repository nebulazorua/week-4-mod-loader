package;

import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.Json;
import haxe.io.Path;
import lime.utils.Assets;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public var pos = [];
	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		animOffsets = new Map<String, Array<Dynamic>>();
		super(x, y);

		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = true;
		var dataArray = ["assets/data"];
		var modList = Json.parse(Assets.getText("assets/data/mods.json"));
		for(fuck in Reflect.fields(modList)){
			dataArray.push("assets/mods/" + Reflect.field(modList,fuck));
		}
	for(directory in dataArray){
			var character = Path.join([directory,"characters","char_" + curCharacter + ".json"]);
			trace(character);
			var exists=true;
			try{
				var data = Assets.getText(character);
			}catch(e){
				trace("fuck " + character + e);
				exists=false;
			};
			if(exists){
				var raw = Assets.getText(character).trim();
				var jsonData = Json.parse(raw);
				var assetPath = directory;
				if(assetPath=="assets/data"){
					assetPath = Path.normalize(assetPath + "/..");
				}
				assetPath += "/images";
				trace(Path.join([assetPath,jsonData.sprites.atlas + ".png"]));
				var tex = FlxAtlasFrames.fromSparrow(Path.join([assetPath,jsonData.sprites.atlas + ".png"]), Path.join([assetPath,jsonData.sprites.atlas + ".xml"]));
				frames = tex;
				for(sprite in Reflect.fields(jsonData.sprites)){
					var spriteName = Reflect.field(jsonData.sprites,sprite);
					if(spriteName != "atlas"){
						switch(Type.getClassName(Type.getClass(spriteName))){
							case 'String':
								animation.addByPrefix(sprite, spriteName, 24, sprite=='idle');
							case 'Array':
								animation.addByIndices(sprite,Reflect.getProperty(spriteName,"0"),Reflect.getProperty(spriteName,"1"),Reflect.getProperty(spriteName,"2"),Reflect.getProperty(spriteName,"3"),false);
						};
					}
				};
				for(animName in Reflect.fields(jsonData.offsets)){
					var offsetData = Reflect.field(jsonData.offsets,animName);
					addOffset(animName,offsetData.x,offsetData.y);
				}
				if(animation.getByName("idle")!=null){
					playAnim("idle");
				}else if(animation.getByName("danceRight")!=null){
					playAnim("danceRight");
				}else{
					playAnim("singUP");
				}
				if(jsonData.FlipX==true)flipX = true;
				pos=[jsonData.pos.x,jsonData.pos.y];
				break;
			}else {
				trace(curCharacter + " ISN'T IN " + Path.join([directory,"characters"]));
			}
	}
}


	override function update(elapsed:Float)
	{
		if (curCharacter != 'bf')
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if(animation.getByName("idle")!=null){
			playAnim("idle");
		}else if(animation.getByName("danceRight")!=null && animation.getByName("danceLeft")!=null){
			danced = !danced;

			if (danced)
				playAnim('danceRight');
			else
				playAnim('danceLeft');
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);
		var daOffset = animOffsets.get(animation.curAnim.name);
		if (animOffsets.exists(animation.curAnim.name))
		{
			offset.set(daOffset[0], daOffset[1]);
		}

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}
