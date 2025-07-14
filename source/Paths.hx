package;

import backend.Constants;
import backend.Song;
import flixel.FlxG;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxSoundAsset;

/**
 * A class for obtaining images, sounds, music, etc.
 */
class Paths
{
    // Files
    public static inline function getImage(id:String):FlxGraphicAsset
        return FlxG.assets.getBitmapData(getFile('images/$id.${Constants.IMAGE_EXT}'), true);

    public static inline function getSound(id:String):FlxSoundAsset
        return FlxG.assets.getSound(getFile('sounds/$id.${Constants.SOUND_EXT}'), true);

    public static inline function getMusic(id:String):FlxSoundAsset
        return FlxG.assets.getSound(getFile('music/$id.${Constants.SOUND_EXT}'), true);

    public static inline function getFont(id:String):String
        return getFile('fonts/$id');

    public static inline function getJson(id:String):String
        return getFile('$id.${Constants.JSON_EXT}');

    public static inline function getFile(id:String):String
        return 'assets/$id';

    // Song
    public static inline function getSong(song:String):FlxSoundAsset
    {
        var songName:String = Song.formatSongName(song);
        return FlxG.assets.getSound(getFile('songs/$songName/song.${Constants.SOUND_EXT}'));
    }

    public static inline function getChart(song:String):String
    {
        var songName:String = Song.formatSongName(song);
        return getJson('songs/$songName/chart');
    }

    public static inline function getMetadata(song:String):String
    {
        var songName:String = Song.formatSongName(song);
        return getJson('songs/$songName/metadata');
    }

    // Util
    public static inline function getText(path:String):String
    {
        if (!exists(path)) return '';
        var content:String = FlxG.assets.getText(path, true);
        return content;
    }

    public static inline function exists(path:String):Bool
        return FlxG.assets.exists(path, null);
}