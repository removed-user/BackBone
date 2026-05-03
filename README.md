How to make your own nixpkgs + lib + your own OS + plus compile every package you use from source every single time, perfectly configured, for you
... without errors, and still have time to eat 

In as few as... a little more than 500 difficult steps!

The perfect 9 pot, 5 pan, 25 skillet, 3 crockpot, 1 crackpot recipe.
<link @theonion>

Condensed to about 7 moderately confusing steps for your convinience.

This is... Ridiculous: and beautiful, and potentially...more reproducible than nixos
Which is especially funny considering that the first step is ignoring stdenv, and using the current hosts tooling

That's fine we'll end up with our own stdenv soon enough, literally... as a side effect of the build process.

That said - "said" stdenv =/= nixpkgs... Obviously; stdenv being a "standard" -
Just means that, here you customize what that standard env is - By integrating with flake-parts, perSystem module.
We basically create a "variety", of tailor-made "stdenv's", per-platform/architecture

Ie: Mac-build =/= Linux-build; but 2 different Mac-builds always the same - after ~4 iterations

The nix didn't solve my problems, and gentoo is too easy distribution

Basically we untangle all of the packages dependency tree's by pointing them to one another.
Which also sounds really funny.

1.) Useful bones
flake-root hasn't been updated in four years, it's a great inlining/vendoring target

Also of note its great for different purposes;

As a simple tool to refer to your (main) flake from its root; 

and / OR

Referring to seperate or different projects under the root.

So naturally, it can be used along with mkderivation or other various Builder functions - 
to package software.

2.) Combining Bones / "The simple base"
Flake-Parts is critical - and a bit of a mess in the repo, with all its templates and whatnot -
for faster/more efficient builds, a "proxy flake" that copies individual files of flake-parts - and
reconstructs it - and even reorganizes it so it makes more sense to me.

The lib is necessary, and even if most of it never changes; I dont want any other downstream flakes to break.
Silly to know when it needs rebuilt, can actually check thaty the hashes do 'NOT' match

Okay, so now everything can be put in its own file and we can Identify the root of a project, so...
At this point already its a massive upgrade from default flakes.

There's a few problems left, to reach what I imagined NixOS was when I first tried it.
###The "build anything, build anywhere distro" isn't that great if its a mess internally - So

#The so called "Dendritic Pattern"
Everything is a flake, every flake is a module

Basically breaking out nearly everything into a module, all imported conditionally.

Combining that with flake-root can provide a way to import all the needed modules for "general system usage";
While determining paths - per flake - per project...
can be used to "somewhat easily" refer to each of those flakes/projects individually, when necessary.

After that a specialArgs function to push default inputs throughout/into each of the dependent flakes for efficiency...
Will be required, because it's about to get hectic

# Scopes
Here's the idea aspects?/scopes the aspects  @vic "denful" - something lib looks like its designed - "partly"
For wrapping mkscope/creating scopes easily, with that maybe it wont be "too" complicated

Or atleast it can be drastically simplified, what "it" is, is creating a new scope for each "project"

projects - of course are the packages you install - which you can use a flake for each of...

Having sourced nixpkgs-lib and propogated the inputs is what makes this possible without an "out of scope" level of evaluation and ending closure.

in short one flake leads to another and eventually you have a whole OS

in long:
1
Determine "Required" Packages:
Strip out nearly everything thats not required for a functioning linux system.
2
Recognize that many of them are built with a variety of different tools;
Need different build flags, different system libraries; etc - Panic!
3. Realize nixpkgs has builders - calm
4. Realize they are opinionated, designed entirely to work within a defined constraint, magical, require stdenv
And trying to override them to set a build arguement that isnt exposed
Is actually 10x harder than it should be to do properly...
5.) Decide not to use nixpkgs

Instead no-nix, Ie: A computer built on nix, without nixpkgs, with nothing but library extensions and flake modules

Pull-in/copy lib+Generic Builders.

meson
gcc
clang
rust
cmake
autotools
c and/or g ++

musl/glibc
any other required compilers/libs

Next to customize - 

set overrides in perSystem - in the builder itself, or a function using them -
For custom/generic compile time options that are generic enough to never fail 

and also create the builder functions for the BIG packages that you'll definitely want to customize 

EG: a minimal optimized kernel, cutting out >=50% of systemd's bloat etc.

Save those build functions as individual flake modules in a structured directory

Set each packages build inputs/requirements to be based on replacements defined by your build functions

Determine paths for "projects":
To manage the pathing alone (a minimal arch install with no wm, often already has 400+ packages)
A generator function may be required for paths; even if its a simple find | grep flake.nix
With all of the flakes found "and also with each one passing its outputs back into the proper attribute"


The idea here is that every package has
A: Its own module/flake
B: Its own Declared dependencies
C: Its own Build arguements
D: The same SpecialArgs Passing it the same "core inputs"; for nix-builders and nix-lib
E: Its own upstream source repository Eg:github/systemd/systemd
F: A series of functions mapping over it for a "rebuild detector"
G: The end result is that each package is reproducible for as long as it - and its dependencies - are version locked.
#To Explain this is "technically reproducible", as long as you have the same inputs and have "primed" your env. Same input-Same output.

# You basically end up with an upstream-tracking ultimately up-to-date collection of functional build processes, where you can easily trim transitive dependencies, and trigger incremental rebuilds. To re-evaluate both your whole computer and your whole life.
#After building each individual package; You can use it any way you see fit
#"Install Seperately as profiles;Package it for other distros" or - next step
H: Symlink farm (be careful with this) Manually select groups "init", "window manager", cli-tools, etc and "thread them back together"



How the fuck do you decide this is a good idea?!

>"
Had a simple mistake in nix experiments at first. It wasn't what I expected or thought it was, I tried to make it that... it didn't appreciate. 
Big consequences though, worst tech issues I've ever had you wwont believe it, here you go.
At the same time I had a bug and an undocumented feature (in git+nix integration) cooperate to delete my system configs, and build scripts, and functions.
Everything - gone, Somehow... all my git history was completely replaced with a repo I'd used as reference for a flake, because pure "eval mode", combined with having git installed and not opting out meant that builds followed your git-flake rather than the local one. 

Instead of building the multi-flake system I'd spent ?? hours on, literally comitted to version control.
I lost all that progress, built off of a different repo's flake... for one of the modules>, and somehow triggered a CI git hook that wiped out my fallback configs, all at in one fell swoop.

I Spent months trying to reconfigure things while every tech item around me was so utterly broken that my computer
had a wireguard vpn connection over cellular, and I was proxying my phone calls through it by accident, which I didnt know was even possible, and I still dont know how the hell I actually sometimes could make any phone calls at all. Ultimately lost the ability to make emergency phone calls. 

On top of that every linux iso was broken, because even if it'd been verified, it got replaced and overwritten while installing?!

Windows was literally not an option, the bootloader now installed on every device didn't support it... and the only windows device I had - for minecraft... was now broken also, after it connected to an enterprise management fleet, got locked down under kerberos, and then it quit booting.

Netboot iso's only pulled from the netboot server now running from my phone.
Figured I was literally under attack, switched to grapheneOS.
Practically did linux from scratch out of necessity, because nix closures were so broken I couldn't remove Kerberos, or the local AWS server, or the mpls subsystem, it had setup...
since everything depended on everything, and removing eza uninstalled the entire desktop environment, which under the pam settings was a literal blackscreening softlock, that required a reboot, which would automatically reinstall everything, start systemd-nspawn, and put me in virtual machine and under a namespace, while formatting my disks with compatibility for linux, mac, bsd, atari, playstation, xbox, AIX, and the fucking toaster.
Sarcasm on that last one, otherwise it was literally THAT bad.

I had to write portions of my firmware, and recode device-id's ... manually, from an efi shell, with hexedit
This prolly seems pretty mild after that description eh?
"
