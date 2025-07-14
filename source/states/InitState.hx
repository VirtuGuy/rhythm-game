package states;

import backend.Conductor;
import backend.Controls;
import backend.Judgement;
import backend.Song;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.system.frontEnds.AssetFrontEnd.FlxAssetType;
import flixel.text.FlxText;
import flixel.util.typeLimit.NextState.InitialState;
import lime.app.Future;
import ui.UIText;

/**
 * An `FlxState` for initializing and setting up the entire game.
 */
class InitState extends FlxState
{
    var initialState:InitialState = ChartEditorState;

    var assets:Array<String> = [];
    var assetType:FlxAssetType;

    var assetText:FlxText;

    override public function create()
    {
        // Setup
        setupGame();
        setupTransition();

        super.create();

        assetText = new UIText(0, 0, 0, 'Loading...', 56);
        assetText.screenCenter();
        add(assetText);

        // TODO: Move the song loading code somewhere else
        Song.loadSongForPlayState('test', HARD);

        // Asset loading
        loadAssets(IMAGE);
    }

    function setupGame()
    {
        FlxG.autoPause = true;
        FlxG.fixedTimestep = false;
        FlxG.mouse.visible = false;
        FlxG.mouse.useSystemCursor = true;
        FlxG.inputs.resetOnStateSwitch = false;
        FlxG.stage.showDefaultContextMenu = false;
        FlxG.stage.quality = LOW;
        FlxObject.defaultMoves = false;

        Conductor.instance = new Conductor();
        Controls.instance = new Controls();

        Judgement.load();
    }

    function setupTransition()
    {
        var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
        diamond.persist = true;
        diamond.destroyOnNoUse = false;

        var transData:TransitionData = new TransitionData(TILES, 0xFF000000, 0.25);
        transData.tileData = { asset: diamond, width: 32, height: 32 };
        transData.direction = new FlxPoint(1, 1);

        FlxTransitionableState.defaultTransIn = transData;
        FlxTransitionableState.defaultTransOut = transData;
    }

    function loadAssets(type:FlxAssetType)
    {
        assetType = type;
        assets = FlxG.assets.list(type);
        nextAsset();
    }

    function nextAsset()
    {
        if (assets.length == 0)
        {
            if (assetType == IMAGE)
                loadAssets(SOUND);
            else
            {
                assetText.text = 'Starting Game...';
                FlxG.switchState(initialState);
            }

            return;
        }

        var assetId:String = assets[0];
        var future:Future<Any> = FlxG.assets.loadAsset(assetId, assetType, true);

        assetText.text = 'Loading... ' + assetId;
        assetText.screenCenter();
        
        future.onComplete(_ -> {
            assets.shift();
            nextAsset();
        });

        future.onError(_ -> {
            trace('An error occurred trying to load ' + assetId);
        });
    }
}