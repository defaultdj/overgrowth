# How To Compile Overgrowth

To run the original Overgrowth game, you need a legally obtained copy of the commercial game data. The source checkout does not contain the original levels, models, textures, audio, or other commercial assets; the checked-in `Data/` directory is development content. If you're on Steam, the `internal_testing` branch may contain newer data files.

You can compile the open-source code without the commercial data. To run the original game, point the build at the installed game root (the directory containing `Data/`) with `-DAUX_DATA=/path/to/Overgrowth`. Do not copy commercial assets into this repository. A total conversion can provide its own assets instead.

These instructions assume you've already managed to download the project and have it in a local folder. There's no need to try and initialize the submodules unless you are an official developer of Wolfire, as those repos are private and primarily used by the build system for deployment. Make sure that the folder depth isn't too great, as this can cause some issues. From now we'll assume you've downloaded the repo into the following folder on windows ```C:\overgrowth``` and ```~/overgrowth``` on unix-like systems.

# Dependencies

## Windows

To compile Overgrowth on windows you'll need the following to be installed before you start:
* CMake https://github.com/Kitware/CMake/releases/download/v3.23.0/cmake-3.23.0-windows-x86_64.msi
* Visual Studio 2022 Community Edition https://visualstudio.microsoft.com/downloads/

## MacOSX

On MacOSX, you'll need to install XCode and CMake before you can compile the project.

After that you may need to start XCode once before building the project, to ensure that everything is configured. You may also have to install the command line XCode tools.

## Generic Linux

You'll need a C++ compiler, CMake, pkg-config, OpenGL development files, SDL2, SDL2_net, GTK 2 (used for native file dialogs), OpenAL, Ogg/Vorbis, libpng, libjpeg, bzip2 and zlib. The project builds FreeType and most engine libraries from the versions vendored in this repository. FreeImage is not a required build dependency.

## Arch Linux

Install the toolchain and system libraries with pacman:

```sh
sudo pacman -S --needed base-devel cmake pkgconf \
  sdl2 sdl2_net gtk2 openal libogg libvorbis \
  libpng libjpeg-turbo bzip2 zlib libglvnd
```

From the repository root, build and (optionally) run using the helper:

```sh
# Build without commercial game data:
./Tools/build_arch_linux.sh

# Build against a purchased Steam installation and launch it:
./Tools/build_arch_linux.sh \
  --data-dir "$HOME/.local/share/Steam/steamapps/common/Overgrowth" --run
```

The path passed to `--data-dir` must be the installed game root, containing `Data/`. Use `OVERGROWTH_DATA_DIR` to avoid passing it each time. Set `OVERGROWTH_BUILD_JOBS` or `OVERGROWTH_BUILD_DIR` to override the number of build jobs or build directory. The helper disables OGDA, RAD telemetry, and Steamworks for a straightforward local build; it does not install system packages automatically.

## Fedora

The following command should install the build dependencies:

```sh
sudo dnf install gcc-c++ cmake make pkgconf-pkg-config \
  'pkgconfig(gl)' 'pkgconfig(sdl2)' 'pkgconfig(SDL2_net)' \
  'pkgconfig(gtk+-2.0)' 'pkgconfig(ogg)' 'pkgconfig(vorbis)' \
  'pkgconfig(openal)' 'pkgconfig(libjpeg)' 'pkgconfig(libpng)' \
  'pkgconfig(bzip2)' 'pkgconfig(zlib)'
```

## Ubuntu / Debian

The following command should install the build dependencies:

```sh
sudo apt install build-essential cmake pkg-config libgl1-mesa-dev \
  libsdl2-dev libsdl2-net-dev libgtk2.0-dev libogg-dev libvorbis-dev \
  libopenal-dev libjpeg-dev libpng-dev libbz2-dev zlib1g-dev
```

# How To Compile

## Windows

1. Make sure you have an installed copy of Overgrowth and find the path to the install. If you've installed the game via Steam you can get the path by right clicking the game in the Steam games list, press Properties, go to Local Files and press Browse. This will open explorer window with the game path, copy that path into your clipboard. example: ```E:\SteamLibrary\steamapps\common\Overgrowth```

2. Go to the Overgrowth git repo folder and create a new subfolder named "Build" example ```C:\overgrowth\Build```

3. Open a windows cmd (alternatively a git bash console) in the build folder you just created.

4. Run the following command ```cmake ../Projects -DAUX_DATA="E:/SteamLibrary/steamapps/common/Overgrowth"```. Replace the path with your own Overgrowth install, and switch the path separators from ```\``` to ```/```

5. Open the generated ```Overgrowth.sln``` file using Visual Studio 2022

6. Press the "Local Windows Debugger" button to compile and start the game.

## MacOSX

1. Go to the folder of the project
2. Create a build directory ```% mkdir Build```
3. Switch the terminal to the directory you just created. ```% cd Build```
4. Run cmake to generate Makefiles, include the path to an already installed instance of Overgrowth ```% cmake ../Projects -DAUX_DATA="/path/to/installed/Overgrowth.app/Contents/MacOS"```
5. Run make to build the game ```% make```
6. Run the game by first moving to the project directory ```% cd ..```
7. Then start the game ```% ./Build/Overgrowth.app/Contents/MacOS/Overgrowth```

## Linux

Run these commands from the repository root. `AUX_DATA` is optional when you only want to compile; it should point to an installed game root (the directory containing `Data/`) when you want to run the original game.

```sh
cmake -S Projects -B Build \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DBUILD_OGDA=OFF
cmake --build Build --parallel "$(nproc)"
./Build/Overgrowth.bin.x86_64
```

To run the original game, add `-DAUX_DATA="/path/to/installed/Overgrowth"` to the `cmake` configure command; the directory must contain `Data/`.

On Linux, the executable is `Build/Overgrowth.bin.x86_64` (not `Build/Release/Overgrowth.x86_64`). The command above is for a 64-bit build. On Arch Linux, the `Tools/build_arch_linux.sh` helper performs the same configure/build steps and can launch the binary with `--run`.
