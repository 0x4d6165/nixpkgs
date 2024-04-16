{ lib
, stdenv
, fetchFromGitea
, libGL
, libX11
, libevdev
, libinput
, libxkbcommon
, pixman
, pkg-config
, scdoc
, udev
, wayland
, wayland-protocols
, wlroots_0_17
, xwayland
, zig_0_11
, withManpages ? true
, xwaylandSupport ? true
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "river";
  version = "0.3.0";

  outputs = [ "out" ] ++ lib.optionals withManpages [ "man" ];

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "river";
    repo = "river";
    rev = "refs/tags/v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-6LZuWx0sC6bW0K7D0PR8hJlVW6i6NIzOOORdMu3Gk5U=";
  };

  nativeBuildInputs = [
    pkg-config
    wayland
    xwayland
    zig_0_11.hook
  ]
  ++ lib.optional withManpages scdoc;

  buildInputs = [
    libGL
    libevdev
    libinput
    libxkbcommon
    pixman
    udev
    wayland-protocols
    wlroots_0_17
  ] ++ lib.optional xwaylandSupport libX11;

  dontConfigure = true;

  zigBuildFlags = lib.optional withManpages "-Dman-pages"
                  ++ lib.optional xwaylandSupport "-Dxwayland";

  postInstall = ''
    install contrib/river.desktop -Dt $out/share/wayland-sessions
  '';

  passthru.providedSessions = [ "river" ];

  meta = {
    homepage = "https://codeberg.org/river/river";
    description = "A dynamic tiling wayland compositor";
    longDescription = ''
      River is a dynamic tiling Wayland compositor with flexible runtime
      configuration.

      Its design goals are:
      - Simple and predictable behavior, river should be easy to use and have a
        low cognitive load.
      - Window management based on a stack of views and tags.
      - Dynamic layouts generated by external, user-written executables. A
        default rivertile layout generator is provided.
      - Scriptable configuration and control through a custom Wayland protocol
        and separate riverctl binary implementing it.
    '';
    changelog = "https://codeberg.org/river/river/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [
      adamcstephens
      moni
      rodrgz
    ];
    mainProgram = "river";
    platforms = lib.platforms.linux;
  };
})
