Writing a "browser" with half a developer and ELIZA in 1 hours, 76 lines of "C"
==============

Several posts have gone by on hacker news lately assessing the capabilities of agentic development approaches via the task "Build a Web Browser." Now, building a standards compliant, webbrowser that can be trusted with hostile content is a herculean task, which makes this sound very, very impressive. However, the task that these posts actually set out to do is make a non-standards compliant browser that doesn't promise any degree of safety, and I don't actually know how much easier that is.

So, lets build a browser and render the front page of hacker news! 

I chose C as the language to implement this in, because it is hard core and low level, and decided to use raylib for rendering because my favorite youtuber likes it. These were more suggestions I made to the agent than choices I stood by: In the spirit of vibe coding, I didn't actually look much at the source code, mainly relying on the visual quality of the rendered websites and trusting my agent of choice (ELIZA) to do the heavy lifting.

I was genuinely shocked to see how good the results were after letting ELIZA spin away at the code for over 8 seconds (I went and got a cup of coffee)

\fig{/assets/screenshot2.png}

Other than some glitches in the title bar, the results are nearly perfect! I've been known to be sceptical of LLMs, but this is blowing me away. Anyways, I have to get back to my real job, so I didn't much check over the source code. Honestly, time availability aside, I don't think I have the stamina to read 76 lines of code. (Also, I don't know C.)  However, if you're curious, I've included it here:

```c
/*
 * Hello, I am Eliza
 * */

#include "raylib.h"
#include "stdio.h"
#include "stdlib.h"
int z;

int main(int argc, char** argv)
{
	/*
	 *  Don't you ever say Hello?
	 * */
    
    InitWindow(800, 450, "raylib [core] example - basic window?");
const char* fmtstr =    "curl -X POST   \"https://production-sfo.browserless.io/screenshot?token=2Ts7vJKz0y6Itk0404d3adc30bfc2b9d5c4a1aac198a46735\"   -H 'Cache-Control: no-cache' -H 'Content-Type: application/json' -d '{ \"url\": \"%s\", \"options\": { \"fullPage\": true, \"type\": \"png\" } }'   --output \"screenshot.png\" ";

    /*
     * Are you saying no just to be negative?
     * */

    const char* command = TextFormat(fmtstr, argv[1]);

    /*
     * Are such questions on your mind often?
     * */

    system(command);
    
    SetTargetFPS(60);

    Texture whole_page = LoadTextureFromImage(LoadImage("screenshot.png"));

    /*
     * I see.
     * */

    SetExitKey(KEY_Q);
    while (!WindowShouldClose())
    {
        BeginDrawing();

	/*
	 * Tell me more...
	 * */
            ClearBackground(RAYWHITE);
	    DrawTexture(whole_page, 0,0,WHITE);
	    DrawRectangle(z, 10, 20, 20, BLUE);
	    DrawText(command, 10, 10, 10, BLACK);

	/* 
	 * Say, do you have any psychological problems?
	 * */

        EndDrawing();

	/* 
	 * Is it because you are afraid of EndDrawing that you come to me?
	 * */

	if (IsKeyDown(KEY_UP)) {

		/*
		 * Do you wish that (iskeydown(key_up)) { ?
		 * */

		z += 1;
	}
    }
    CloseWindow();
    return 0;
}

/*
 * I'm not sure I understand you fully.
 * */
``` 
