examples: cgi scripts. each page of the webpage is a script, scripts can import common libraries. orchestrator is apache

machine learning: each training or inference use case is a script, orchestrator is bash. bash should be your default orchestrator unless you have a very good reason

Game development: each level is a script. this is the point of this post as this dedign pattern is underutilized in game dev. valuable to promote the otherwise tricky combo of debuggabillity and thematically diverse levels. may have to roll own orchestrator.

OG gnu-linux: linux is the library, gnu are the scripts

Rules of the design pattern: 

scripts may not run in the same memory space. if at all possible, they shouldn’t run at the same time, or at least shouldn’t be able to tell that they are running at the same time

scripts may only communicate through persistent storage: cookie, disk or database. limit this communication whenever possible.

scripts ABSOLUTELY may not import each other
 
scripts should be single file

Your orchestrator should be off the shelf. Options: bash, apache, 

Completely deleting any script should not affect the functionality of the project, except that you can’t run the script any more

changes in which script is active should be in response to user input. the user may have the option to queue up a sequence of such inputs, or repeat that sequence, via affordances built into the orchestrator.

Library code should be high quality: linted, formatted, tested, documented. Library code should not have global state. Library code should not contain duplicated code. library code should only have a minimal set of third party dependencies.

Absolutions of the design pattern:

you are permitted to do whatever the hell you want within scripts. you can have global state, you can copy paste code willy nilly within or between scripts, you can add external dependencies to scripts on a moments notice, you can vibe code scripts without even reading the diffs. 

typical workflow: copy paste code between scripts as a default action. if same code has been copy pasted three times, lift it into the library or the documentation of the library. if the code fits well into the class or function abstractions, use them! if it doesn’t, don’t force it with a million arguments- instead, write a TUTORIAL and add it to the library’s documentation, and going forward copy and paste the code from the tutorial into the script and then modify it to suite, instead of from script to script.

Library code should be unit tested, scripts should be end-to-end tested via the orchestrator, not by writing scripts that import scripts

I want to expand more on the class / function / tutorial triad. in particular, I think that tutorial is the correct way for procedural code to reside in a library, with the most overlooked case being model training.

the rules of the script / library / orchestrator design pattern are tuned to allow tutorial to exist as a first class unit of code re-use

Tutorials are library, not script. They require high quality tests just like functions or classes in the library.
Testing of scripts is a good idea too but it is permitted to not, or even to let scripts rot.
Having a hodgepodge of independent orchestrators is fine, even encouraged. it’s custom interscript-dependencies in the orchestrator that needs stamping out with prejudice. for example, the unit tests for the library are secretly scripts, with e.g. jest as the orchestrator. Jupyter is a common orchestrator, even though it sucks. This is the only project architecture that has a chance of surviving contact with Jupyter enthusiasts.

The SLO architecture is not a panacea! It's just one option for organizing a project. Not every code base should be Script / Library / Orchestrator- that would be just as crazy as dogmatically breaking every codebase into microservices, orgranizing every single codebase into Model / View / Controller, or only ever coding in monolithic frameworks like Rails or Unity. 


