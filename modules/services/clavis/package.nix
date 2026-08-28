# /etc/nixos/modules/services/clavis/package.nix
# Clavis Shell + key-cli + keytop 的 nix 打包
# 来源: https://github.com/StatIndet/quickshell (Clavis Shell)
#       https://github.com/StatIndet/key-cli
#       https://github.com/StatIndet/keytop
#
# 构建依赖（全部来自 nixpkgs）:
#   - Clavis Shell: Qt6 + Qt6Keychain + libpipewire + libcava + quickshell
#   - key-cli: 纯 Python wheel（setuptools）
#   - keytop: Qt6 Core + ncursesw
{
  lib,
  stdenv,
  cmake,
  ninja,
  qt6Packages,
  quickshell,
  pipewire,
  libcava,
  ncurses,
  fftw,
  pkg-config,
  git,
  patchelf,
  python3,
  fetchFromGitHub,
  wrapQtAppsHook,
  ...
}:

# ═══════════════ key-cli (纯 Python) ═══════════════
let
  key-cli = python3.pkgs.buildPythonApplication {
    pname = "key-cli";
    version = "0.2.0";
    src = ./key-cli;
    pyproject = true;
    build-system = [ python3.pkgs.setuptools ];
    # 零 Python 依赖（运行时依赖都是系统命令）
    propagatedBuildInputs = [ ];
  };

  # ═══════════════ keytop (C++ 系统监测) ═══════════════
  keytop = stdenv.mkDerivation {
    pname = "keytop";
    version = "0.1.0";
    src = ./keytop;
    nativeBuildInputs = [
      cmake
      ninja
      pkg-config
      qt6Packages.wrapQtAppsHook
    ];
    buildInputs = [
      qt6Packages.qtbase
      qt6Packages.qtkeychain
      ncurses # ncursesw（pkg-config 名称 ncursesw 由 ncurses 提供）
    ];
    cmakeFlags = [ "-DCMAKE_BUILD_TYPE=Release" ];
  };

  # ═══════════════ Clavis Shell (CMake + C++ + QML) ═══════════════
  clavis-shell = stdenv.mkDerivation {
    pname = "clavis-shell";
    version = "0.2.0";
    src = ./clavis-shell;
    nativeBuildInputs = [
      cmake
      ninja
      pkg-config
      qt6Packages.wrapQtAppsHook
      git
      patchelf
    ];
    buildInputs = [
      qt6Packages.qtbase
      qt6Packages.qtdeclarative
      qt6Packages.qtshadertools
      qt6Packages.qttools
      qt6Packages.qt5compat # Qt5Compat.GraphicalEffects（Clavis 毛玻璃用）
      qt6Packages.qtlottie # Qt.labs.lottieqt（天气动画）
      qt6Packages.qtkeychain
      quickshell
      pipewire
      libcava
      fftw # libcava 头文件需要 fftw3.h
    ];
    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Release"
      "-DCLAVIS_RELEASE=nixpkgs"
      # QML 插件避免把 build 目录 RPATH 带进产物（nix 要求无 /build 引用）
      "-DCMAKE_SKIP_BUILD_RPATH=ON"
    ];
    # 安装 systemd user service
    postInstall = ''
      mkdir -p $out/etc/systemd/user
      cp ${./clavis-shell}/packaging/systemd/user/clavis-shell.service $out/etc/systemd/user/
      # M3Shapes 的 libM3Shapes.so 链接在 core/plugin/m3shapes/ 但 CMake 未安装它
      # （上游打包 bug: 只装了 qml/M3Shapes/ 的 plugin）。补拷到安装目录。
      find . -name "libM3Shapes.so*" -exec cp {} $out/lib/qt6/qml/M3Shapes/ \; 2>/dev/null || true
    '';
    # QML 插件需要 RPATH 指向自己的库目录（libClavisXxx.so 与 plugin.so 同目录）
    # CMake 的 install RPATH 保留 /build 路径（SKIP_BUILD_RPATH 未完全生效），
    # 运行时找不到同目录库。用 preFixup 统一替换为真实目录。
    preFixup = ''
      for so in $(find $out -name "*.so"); do
        dir=$(dirname $so)
        rpath=$(patchelf --print-rpath "$so" 2>/dev/null || true)
        # 去掉 /build 引用，追加同目录
        clean_rpath=$(echo "$rpath" | tr ':' '\n' | grep -v '^/build/' | tr '\n' ':')
        patchelf --set-rpath "$clean_rpath$dir" "$so" 2>/dev/null || true
      done
    '';
    meta = with lib; {
      description = "Clavis desktop shell for niri (Quickshell/QML)";
      homepage = "https://github.com/StatIndet/quickshell";
      license = licenses.gpl3;
    };
  };
in
{
  inherit clavis-shell key-cli keytop;
}
