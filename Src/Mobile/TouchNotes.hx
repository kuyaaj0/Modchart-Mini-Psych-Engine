package Mobile;

import flixel.FlxSprite;
import Backend.Settings;
import Game.Funkin.PlayState;

class TouchNotes
{
    public var mobileControls:MobileControls;
    public var noteSprites:Array<FlxSprite>;
    public var playState:PlayState;

    public function new(mobileControls:MobileControls, playState:PlayState)
    {
        this.mobileControls = mobileControls;
        this.playState = playState;
        noteSprites = [];
    }

    // Add a note sprite to track
    public function addNote(note:FlxSprite):Void
    {
        noteSprites.push(note);
    }

    // Update notes input
    public function update():Void
    {
        if(Settings.keyboardMode) return;

        for(i in 0...noteSprites.length)
        {
            var note = noteSprites[i];

            // Check if mobile lane button is pressed for this lane
            if(mobileControls.isLanePressed(i))
            {
                playState.hitNote(i);
                continue;
            }

            // Check if note itself was clicked (official mobile input)
            if(Settings.mobileClickOnNotePosition && mobileControls.checkNoteClick(note.x, note.y, note.width, note.height))
            {
                playState.hitNote(i);
            }
        }
    }
}
