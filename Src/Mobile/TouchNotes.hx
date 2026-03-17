package Mobile;

import flixel.FlxSprite;
import Backend.Settings;

class TouchNotes
{
    public var mobileControls:MobileControls;
    public var noteSprites:Array<FlxSprite>;

    public function new(mobileControls:MobileControls)
    {
        this.mobileControls = mobileControls;
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

        for(note in noteSprites)
        {
            if(mobileControls.checkNoteClick(note.x, note.y, note.width, note.height))
            {
                // Trigger note hit logic here
                hitNote(note);
            }
        }
    }

    private function hitNote(note:FlxSprite):Void
    {
        // Placeholder: connect with your PlayState note hit system
        trace('Note pressed at: ' + note.x + ', ' + note.y);
    }
}
