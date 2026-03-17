{ config, pkgs, lib, ... }:

{
  # KDE Plasma 桌面环境配置
  home.pointerCursor = {
    gtk.enable = true;
    plasma.enable = true;
  };

  # 全局外观和主题
  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = "org.kde.breezetwilight.desktop";
  };

  # KDE 配置文件
  xdg.configFile = {
    # kdeglobals - 全局 KDE 配置
    "kdeglobals".text = ''
      [General]
      ColorSchemeHash=f08fce0cfa831db116d71bd9c8b9110bd75731be
      XftHintStyle=hintslight
      XftSubPixel=none
      accentColorFromWallpaper=true
      font=Noto Sans CJK SC,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
      menuFont=Noto Sans CJK SC,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
      smallestReadableFont=Noto Sans CJK SC,8,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
      toolBarFont=Noto Sans CJK SC,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1

      [Icons]
      Theme=Papirus

      [KDE]
      LookAndFeelPackage=org.kde.breezetwilight.desktop

      [KFileDialog Settings]
      Allow Expansion=false
      Automatically select filename extension=true
      Breadcrumb Navigation=true
      Decoration position=2
      Show Full Path=false
      Show Inline Previews=true
      Show Preview=false
      Show Speedbar=true
      Show hidden files=false
      Sort by=Name
      Sort directories first=true
      Sort hidden files last=false
      Sort reversed=false
      Speedbar Width=90
      View Style=DetailTree

      [WM]
      activeBackground=227,229,231
      activeBlend=227,229,231
      activeFont=Noto Sans CJK SC,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
      activeForeground=35,38,41
      inactiveBackground=239,240,241
      inactiveBlend=239,240,241
      inactiveForeground=112,125,138
    '';

    # dolphinrc - Dolphin 文件管理器配置
    "dolphinrc".text = ''
      [General]
      Version=202

      [KFileDialog Settings]
      Places Icons Auto-resize=false
      Places Icons Static Size=22

      [MainWindow]
      MenuBar=Disabled
    '';

    # kwinrc - KWin 窗口管理器配置
    "kwinrc".text = ''
      [Desktops]
      Number=1
      Rows=1

      [ElectricBorders]
      BottomLeft=ApplicationLauncher

      [Tiling]
      padding=4

      [Wayland]
      InputMethod=/run/current-system/sw/share/applications/org.fcitx.Fcitx5.desktop

      [Xwayland]
      Scale=1
    '';

    # plasmashellrc - Plasma Shell 配置
    "plasmashellrc".text = ''
      [PlasmaViews][Panel 2]
      floating=1

      [PlasmaViews][Panel 2][Defaults]
      thickness=44

      [PlasmaViews][Panel 26]
      floating=1
      panelVisibility=2

      [PlasmaViews][Panel 26][Defaults]
      thickness=44
    '';

    # arkrc - Ark 压缩软件配置
    "arkrc".text = ''
      [General]
      LockSidebar=true
      ShowSidebar=true

      [MainWindow]
      StatusBar=Disabled
    '';

    # gwenviewrc - Gwenview 图片查看器配置
    "gwenviewrc".text = ''
      [General]
      LastUsedVersion=210800

      [MainWindow]
      MenuBar=Disabled
    '';

    # katerc - Kate 文本编辑器配置
    "katerc".text = ''
      [General]
      Days Meta Infos=30
      Save Meta Infos=true
      Show Full Path in Title=false
      Show Menu Bar=true
      Show Status Bar=true
      Show Tab Bar=true
      Show Url Nav Bar=true

      [KTextEditor Renderer]
      Animate Bracket Matching=false
      Auto Color Theme Selection=true
      Color Theme=Breeze Light
      Line Height Multiplier=1
      Show Indentation Lines=false
      Show Whole Bracket Expression=false
      Text Font=Hack,10,-1,7,400,0,0,0,0,0,0,0,0,0,0,1
      Word Wrap Marker=false

      [filetree]
      editShade=183,220,246
      listMode=false
      middleClickToClose=false
      shadingEnabled=true
      showCloseButton=false
      showFullPathOnRoots=false
      showToolbar=true
      sortRole=0
      viewShade=211,190,222
    '';

    # konsolerc - Konsole 终端配置
    "konsolerc".text = ''
      [General]
      ConfigVersion=1

      [UiSettings]
      ColorScheme=Breeze
    '';
  };

  # 快捷键配置
  # 注意：Home Manager 没有直接的模块来管理 kglobalshortcutsrc
  # 我们使用 xdg.configFile 来创建它
  xdg.configFile."kglobalshortcutsrc".text = ''
    [ActivityManager]
    switch-to-activity-08acb5c3-defc-4df0-9aee-9016259f3dd6=none,none，切换到活动"默认"

    [KDE Keyboard Layout Switcher]
    Switch to Last-Used Keyboard Layout=Meta+Alt+L,Meta+Alt+L，切换到上次使用过的键盘布局
    Switch to Next Keyboard Layout=Meta+Alt+K,Meta+Alt+K，切换到下一个键盘布局

    [kmix]
    decrease_microphone_volume=Microphone Volume Down,Microphone Volume Down，降低麦克风音量
    decrease_volume=Volume Down,Volume Down，降低音量
    decrease_volume_small=Shift+Volume Down,Shift+Volume Down，音量降低 1%
    increase_microphone_volume=Microphone Volume Up,Microphone Volume Up，提高麦克风音量
    increase_volume=Volume Up,Volume Up，提高音量
    increase_volume_small=Shift+Volume Up,Shift+Volume Up，音量提高 1%
    mic_mute=Microphone Mute,Microphone Mute，麦克风静音
    mute=Volume Mute,Volume Mute，静音

    [ksmserver]
    Lock Session=Meta+L,Meta+L，锁定会话

    [kwin]
    Activate Window Demanding Attention=Meta+Ctrl+A,Meta+Ctrl+A，激活请求注意的窗口
    Edit Tiles=Meta+T,Meta+T，磁贴编辑器开关
    Expose=Ctrl+F9,Ctrl+F9，显示/隐藏窗口平铺 (当前桌面)
    ExposeAll=Ctrl+F10,Ctrl+F10，显示/隐藏窗口平铺 (全部桌面)
    ExposeClass=Ctrl+F7,Ctrl+F7，显示/隐藏窗口平铺 (窗口类)
    Grid View=Meta+G,Meta+G，切换网格视图
    Kill Window=Meta+Ctrl+Esc,Meta+Ctrl+Esc，强制终止窗口
    MoveMouseToCenter=Meta+F6,Meta+F6，移动鼠标到中央
    MoveMouseToFocus=Meta+F5,Meta+F5，移动鼠标到焦点
    Overview=Meta+W,Meta+W，显示/隐藏桌面总览
    Show Desktop=Meta+D,Meta+D，暂时显示桌面
    Switch One Desktop Down=Meta+Ctrl+Down,Meta+Ctrl+Down，切换到下方桌面
    Switch One Desktop Up=Meta+Ctrl+Up,Meta+Ctrl+Up，切换到上方桌面
    Switch One Desktop to the Left=Meta+Ctrl+Left,Meta+Ctrl+Left，切换到左侧桌面
    Switch One Desktop to the Right=Meta+Ctrl+Right,Meta+Ctrl+Right，切换到右侧桌面
    Switch Window Down=Meta+Alt+Down,Meta+Alt+Down，切换到下面的窗口
    Switch Window Left=Meta+Alt+Left,Meta+Alt+Left，切换到左侧的窗口
    Switch Window Right=Meta+Alt+Right,Meta+Alt+Right，切换到右侧的窗口
    Switch Window Up=Meta+Alt+Up,Meta+Alt+Up，切换到上面的窗口
    Switch to Desktop 1=Ctrl+F1,Ctrl+F1，切换到桌面 1
    Switch to Desktop 2=Ctrl+F2,Ctrl+F2，切换到桌面 2
    Switch to Desktop 3=Ctrl+F3,Ctrl+F3，切换到桌面 3
    Switch to Desktop 4=Ctrl+F4,Ctrl+F4，切换到桌面 4
    Toggle Night Color=none,none，暂停/继续夜间色温
    Walk Through Windows=Meta+Tab,Meta+Tab，遍历窗口
    Walk Through Windows (Reverse)=Meta+Shift+Tab,Meta+Shift+Tab，遍历窗口 (反向)
    Window Close=Alt+F4,Alt+F4，关闭窗口
    Window Maximize=Meta+PgUp,Meta+PgUp，最大化窗口
    Window Minimize=Meta+PgDown,Meta+PgDown，最小化窗口
    Window Operations Menu=Alt+F3,Alt+F3，窗口菜单
    Window Quick Tile Bottom=Meta+Down,Meta+Down，快速铺放窗口到下方
    Window Quick Tile Left=Meta+Left,Meta+Left，快速铺放窗口到左侧
    Window Quick Tile Right=Meta+Right,Meta+Right，快速铺放窗口到右侧
    Window Quick Tile Top=Meta+Up,Meta+Up，快速铺放窗口到上方
    disableInputCapture=Meta+Shift+Esc,Meta+Shift+Esc，禁用活动输入捕获
    view_actual_size=Meta+0,Meta+0，缩放为实际大小
    view_zoom_in=Meta+Plus,Meta+Plus，放大
    view_zoom_out=Meta+Minus,Meta+Minus，缩小

    [mediacontrol]
    nextmedia=Media Next,Media Next，播放下一首媒体
    pausemedia=Media Pause,Media Pause，暂停媒体播放
    playpausemedia=Media Play,Media Play，播放/暂停媒体播放
    previousmedia=Media Previous,Media Previous，播放上一首媒体
    stopmedia=Media Stop,Media Stop，停止媒体播放

    [org_kde_powerdevil]
    Decrease Keyboard Brightness=Keyboard Brightness Down,Keyboard Brightness Down，降低键盘亮度
    Decrease Screen Brightness=Monitor Brightness Down,Monitor Brightness Down，降低屏幕亮度
    Decrease Screen Brightness Small=Shift+Monitor Brightness Down,Shift+Monitor Brightness Down，降低屏幕亮度 1%
    Hibernate=Hibernate,Hibernate，休眠
    Increase Keyboard Brightness=Keyboard Brightness Up,Keyboard Brightness Up，提高键盘亮度
    Increase Screen Brightness=Monitor Brightness Up,Monitor Brightness Up，提高屏幕亮度
    Increase Screen Brightness Small=Shift+Monitor Brightness Up,Shift+Monitor Brightness Up，提高屏幕亮度 1%
    PowerDown=Power Down,Power Down，断电
    PowerOff=Power Off,Power Off，关机
    Sleep=Sleep,Sleep，挂起
    Toggle Keyboard Backlight=Keyboard Light On/Off,Keyboard Light On/Off，开关键盘背光
    powerProfile=Battery,Battery，切换电源管理方案

    [plasmashell]
    activate application launcher=Meta,Meta，激活应用程序启动器
    activate task manager entry 1=Meta+1,Meta+1，激活任务管理器条目 1
    activate task manager entry 2=Meta+2,Meta+2，激活任务管理器条目 2
    activate task manager entry 3=Meta+3,Meta+3，激活任务管理器条目 3
    activate task manager entry 4=Meta+4,Meta+4，激活任务管理器条目 4
    activate task manager entry 5=Meta+5,Meta+5，激活任务管理器条目 5
    activate task manager entry 6=Meta+6,Meta+6，激活任务管理器条目 6
    activate task manager entry 7=Meta+7,Meta+7，激活任务管理器条目 7
    activate task manager entry 8=Meta+8,Meta+8，激活任务管理器条目 8
    activate task manager entry 9=Meta+9,Meta+9，激活任务管理器条目 9
    manage activities=Meta+Q,Meta+Q，显示活动切换器
    next activity=Meta+A,Meta+A，遍历活动
    previous activity=Meta+Shift+A,Meta+Shift+A，遍历活动 (反向)
    show dashboard=Ctrl+F12,Ctrl+F12，显示桌面
  '';

  # 桌面小部件配置
  xdg.configFile."plasma-org.kde.plasma.desktop-appletsrc".text = ''
    [ActionPlugins][0]
    MiddleButton;NoModifier=org.kde.paste
    RightButton;NoModifier=org.kde.contextmenu

    [ActionPlugins][1]
    RightButton;NoModifier=org.kde.contextmenu

    [Containments][25]
    activityId=08acb5c3-defc-4df0-9aee-9016259f3dd6
    formfactor=0
    immutability=1
    lastScreen=0
    location=0
    plugin=org.kde.plasma.folder
    wallpaperplugin=org.kde.image

    [Containments][25][General]
    sortMode=-1

    [Containments][25][Wallpaper][org.kde.image][General]
    FillMode=1
    Image=file:///home/zhangchongjie/Pictures/Wallpapers/Mountain

    [Containments][26]
    formfactor=2
    immutability=1
    lastScreen=0
    location=4
    plugin=org.kde.panel
    wallpaperplugin=org.kde.image

    [Containments][26][Applets][27]
    immutability=1
    plugin=org.kde.plasma.kickoff

    [Containments][26][Applets][27][Configuration]
    popupHeight=510
    popupWidth=601

    [Containments][26][Applets][28]
    immutability=1
    plugin=org.kde.plasma.pager

    [Containments][26][Applets][29]
    immutability=1
    plugin=org.kde.plasma.icontasks

    [Containments][26][Applets][29][Configuration][General]
    launchers=applications:systemsettings.desktop,preferred://filemanager,preferred://browser

    [Containments][26][Applets][30]
    immutability=1
    plugin=org.kde.plasma.marginsseparator

    [Containments][26][Applets][31]
    formfactor=0
    immutability=1
    location=0
    plugin=org.kde.plasma.systemtray
    popupHeight=432
    popupWidth=432
    wallpaperplugin=org.kde.image

    [Containments][26][Applets][31][Applets][32]
    immutability=1
    plugin=org.kde.plasma.cameraindicator

    [Containments][26][Applets][31][Applets][33]
    immutability=1
    plugin=org.kde.plasma.clipboard

    [Containments][26][Applets][31][Applets][34]
    immutability=1
    plugin=org.kde.plasma.manage-inputmethod

    [Containments][26][Applets][31][Applets][35]
    immutability=1
    plugin=org.kde.kdeconnect

    [Containments][26][Applets][31][Applets][36]
    immutability=1
    plugin=org.kde.plasma.keyboardlayout

    [Containments][26][Applets][31][Applets][37]
    immutability=1
    plugin=org.kde.plasma.devicenotifier

    [Containments][26][Applets][31][Applets][38]
    immutability=1
    plugin=org.kde.plasma.notifications

    [Containments][26][Applets][31][Applets][39]
    immutability=1
    plugin=org.kde.kscreen

    [Containments][26][Applets][31][Applets][40]
    immutability=1
    plugin=org.kde.plasma.keyboardindicator

    [Containments][26][Applets][31][Applets][41]
    immutability=1
    plugin=org.kde.plasma.networkmanagement

    [Containments][26][Applets][31][Applets][42]
    immutability=1
    plugin=org.kde.plasma.volume

    [Containments][26][Applets][31][Applets][43]
    immutability=1
    plugin=org.kde.plasma.weather

    [Containments][26][Applets][31][Applets][46]
    immutability=1
    plugin=org.kde.plasma.brightness

    [Containments][26][Applets][31][Applets][47]
    immutability=1
    plugin=org.kde.plasma.battery

    [Containments][26][Applets][31][Applets][48]
    immutability=1
    plugin=org.kde.plasma.mediacontroller

    [Containments][26][Applets][31][General]
    extraItems=org.kde.plasma.cameraindicator,org.kde.plasma.clipboard,org.kde.plasma.manage-inputmethod,org.kde.plasma.keyboardlayout,org.kde.plasma.devicenotifier,org.kde.plasma.mediacontroller,org.kde.plasma.notifications,org.kde.kscreen,org.kde.plasma.battery,org.kde.plasma.brightness,org.kde.plasma.keyboardindicator,org.kde.plasma.networkmanagement,org.kde.plasma.volume,org.kde.plasma.weather,org.kde.kdeconnect
    knownItems=org.kde.plasma.cameraindicator,org.kde.plasma.clipboard,org.kde.plasma.manage-inputmethod,org.kde.plasma.keyboardlayout,org.kde.plasma.devicenotifier,org.kde.plasma.mediacontroller,org.kde.plasma.notifications,org.kde.kscreen,org.kde.plasma.battery,org.kde.plasma.brightness,org.kde.plasma.keyboardindicator,org.kde.plasma.networkmanagement,org.kde.plasma.volume,org.kde.plasma.weather,org.kde.kdeconnect

    [Containments][26][Applets][44]
    immutability=1
    plugin=org.kde.plasma.digitalclock

    [Containments][26][Applets][44][Configuration][Appearance]
    enabledCalendarPlugins=alternatecalendar,astronomicalevents,holidaysevents
    showWeekNumbers=true

    [Containments][26][Applets][45]
    immutability=1
    plugin=org.kde.plasma.showdesktop

    [Containments][26][General]
    AppletOrder=27;28;29;30;31;44;45
  '';

  # 字体配置（需要确保系统已安装相应字体）
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    # 中文字体
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    # 英文字体
    hack-font
    # 图标主题
    papirus-icon-theme
  ];

  # GTK 配置（与 KDE 集成）
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
  };
}