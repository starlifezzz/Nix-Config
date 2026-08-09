# /etc/nixos/home/fcitx5.nix
# fcitx5 输入法用户级配置（声明式托管）
# 官方文档:
#   xdg.configFile: https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.configFile
#   sessionVariables: https://nix-community.github.io/home-manager/options.xhtml#opt-home.sessionVariables
# 设计说明:
#   - 系统级 addons 由 modules/services/desktop.nix 的 i18n.inputMethod.fcitx5.addons 提供
#   - 本文件仅托管 ~/.config/fcitx5/ 下的用户配置（config / profile / conf/*.conf）
#   - cached_layouts 为运行时动态缓存，不托管
#   - ~/.local/share/fcitx5/rime/ 为用户词库数据，多机不共享，不托管（决策 1）
#   - 声明式托管后 fcitx5-configtool 的 GUI 修改不再持久化（决策 2 已确认接受）
#   - force = true: 首次 switch 时覆盖已存在的旧配置文件（内容一致，无数据丢失）
# 风险提示（决策 3）:
#   GTK_IM_MODULE / QT_IM_MODULE 在 Wayland 下必须留空字符串（禁用 XIM 桥接，
#   改由 Wayland 原生 text-input 协议输入），原值迁移自 home/kde.nix，
#   若删除会导致部分程序无法输入中文，且 fcitx5 启动时提示 IM module 错误。
{ ... }:

{
  # ═══════════════════════════════════════════════════════════
  # 输入法环境变量（迁移自 home/kde.nix，值保持不变）
  # ═══════════════════════════════════════════════════════════
  home.sessionVariables = {
    # Wayland 下 GTK/QT 走原生输入法协议，必须为空字符串（禁用 XIM 桥接）
    GTK_IM_MODULE = "";
    QT_IM_MODULE = "";
    # XIM 客户端识别 fcitx5（兼容老程序/Java）
    XMODIFIERS = "@im=fcitx";
    # SDL 应用输入法模块
    SDL_IM_MODULE = "fcitx";
  };

  # ═══════════════════════════════════════════════════════════
  # fcitx5 配置文件声明式托管
  # 写入位置: $XDG_CONFIG_HOME/fcitx5/<path>
  # ═══════════════════════════════════════════════════════════
  xdg.configFile = {
    # ── 全局配置 config ──────────────────────────────────────
    "fcitx5/config" = {
      force = true;
      text = ''
        [Hotkey]
        # 按住切换键的修饰键时进行轮换切换
        EnumerateWithTriggerKeys=True
        # 向前切换输入法
        EnumerateForwardKeys=
        # 向后切换输入法
        EnumerateBackwardKeys=
        # 轮换输入法时跳过第一个输入法
        EnumerateSkipFirst=False
        # 触发修饰键快捷键的时限 (毫秒)
        ModifierOnlyKeyTimeout=250

        [Hotkey/TriggerKeys]
        0=Control+space
        1=Zenkaku_Hankaku

        [Hotkey/ActivateKeys]
        0=Hangul_Hanja

        [Hotkey/DeactivateKeys]
        0=Hangul_Romaja

        [Hotkey/AltTriggerKeys]
        0=Shift_L

        [Hotkey/EnumerateGroupForwardKeys]
        0=Super+space

        [Hotkey/EnumerateGroupBackwardKeys]
        0=Shift+Super+space

        [Hotkey/PrevPage]
        0=Up

        [Hotkey/NextPage]
        0=Down

        [Hotkey/PrevCandidate]
        0=Shift+Tab

        [Hotkey/NextCandidate]
        0=Tab

        [Hotkey/TogglePreedit]
        0=Control+Alt+P

        [Behavior]
        # 默认激活输入法
        ActiveByDefault=False
        # 重新聚焦时重置状态
        resetStateWhenFocusIn=No
        # 共享输入状态
        ShareInputState=Program
        # 在程序中显示预编辑文本
        PreeditEnabledByDefault=True
        # 切换输入法时显示输入法信息
        ShowInputMethodInformation=True
        # 在焦点更改时显示输入法信息
        showInputMethodInformationWhenFocusIn=False
        # 显示紧凑的输入法信息
        CompactInputMethodInformation=True
        # 显示第一个输入法的信息
        ShowFirstInputMethodInformation=True
        # 缺省每页候选词
        DefaultPageSize=5
        # 覆盖 XKB 选项
        OverrideXkbOption=False
        # 自定义 XKB 选项
        CustomXkbOption=
        # Force Enabled Addons
        EnabledAddons=
        # Preload input method to be used by default
        PreloadInputMethod=True
        # 允许在密码框中使用输入法
        AllowInputMethodForPassword=True
        # 输入密码时显示预编辑文本
        ShowPreeditForPassword=False
        # 保存用户数据的时间间隔（以分钟为单位）
        AutoSavePeriod=30

        [Behavior/DisabledAddons]
        0=cloudpinyin
        1=dbusfrontend
        2=fcitx4frontend
        3=ibusfrontend
        4=pinyin
        5=xim
      '';
    };

    # ── 输入法列表 profile ───────────────────────────────────
    "fcitx5/profile" = {
      force = true;
      text = ''
        [Groups/0]
        # Group Name
        Name=默认
        # Layout
        Default Layout=us
        # Default Input Method
        DefaultIM=rime

        [Groups/0/Items/0]
        # Name
        Name=rime
        # Layout
        Layout=

        [GroupOrder]
        0=默认
      '';
    };

    # ── 经典界面外观 conf/classicui.conf ─────────────────────
    "fcitx5/conf/classicui.conf" = {
      force = true;
      text = ''
        # 垂直候选列表
        Vertical Candidate List=True
        # 使用鼠标滚轮翻页
        WheelForPaging=True
        # 字体
        Font="Sans 10"
        # 菜单字体
        MenuFont="Sans 10"
        # 托盘字体
        TrayFont="Sans Bold 10"
        # 托盘标签轮廓颜色
        TrayOutlineColor=#000000
        # 托盘标签文本颜色
        TrayTextColor=#ffffff
        # 优先使用文字图标
        PreferTextIcon=True
        # 在图标中显示布局名称
        ShowLayoutNameInIcon=True
        # 使用输入法的语言来显示文字
        UseInputMethodLanguageToDisplayText=True
        # 主题
        Theme=Material-Color-teal
        # 深色主题
        DarkTheme=plasma
        # 跟随系统浅色/深色设置
        UseDarkTheme=True
        # 当被主题和桌面支持时使用系统的重点色
        UseAccentColor=True
        # 在 X11 上针对不同屏幕使用单独的 DPI
        PerScreenDPI=False
        # 固定 Wayland 的字体 DPI
        ForceWaylandDPI=0
        # 在 Wayland 下启用分数缩放
        EnableFractionalScale=True
      '';
    };

    # ── Rime 引擎 conf/rime.conf ─────────────────────────────
    "fcitx5/conf/rime.conf" = {
      force = true;
      text = ''
        # 预编辑模式
        PreeditMode="Composing text"
        # 共享输入状态
        InputState=All
        # 将嵌入式预编辑文本的光标固定在开头
        PreeditCursorPositionAtBeginning=True
        # 切换输入法时的行为
        SwitchInputMethodBehavior="Commit commit preview"
        # 重新部署
        Deploy=
        # 同步
        Synchronize=
      '';
    };

    # ── 通知 conf/notifications.conf ─────────────────────────
    "fcitx5/conf/notifications.conf" = {
      force = true;
      text = ''
        # 隐藏通知
        HiddenNotifications=
      '';
    };

    # ── 简繁转换 conf/chttrans.conf ──────────────────────────
    "fcitx5/conf/chttrans.conf" = {
      force = true;
      text = ''
        # 转换引擎
        Engine=OpenCC
        # 启用的输入法
        EnabledIM=
        # 简转繁的 OpenCC 配置
        OpenCCS2TProfile=default
        # 繁转简的 OpenCC 配置
        OpenCCT2SProfile=default

        [Hotkey]
        0=Control+Shift+F
      '';
    };

    # ── 标点 conf/punctuation.conf ───────────────────────────
    "fcitx5/conf/punctuation.conf" = {
      force = true;
      text = ''
        # 字母或者数字之后输入半角标点
        HalfWidthPuncAfterLetterOrNumber=True
        # 同时输入成对标点 (例如引号)
        TypePairedPunctuationsTogether=False
        # Enabled
        Enabled=True

        [Hotkey]
        0=Control+period
      '';
    };

    # ── 拼音引擎 conf/pinyin.conf ────────────────────────────
    "fcitx5/conf/pinyin.conf" = {
      force = true;
      text = ''
        # 双拼方案
        ShuangpinProfile=Ziranma
        # 显示当前双拼模式
        ShowShuangpinMode=True
        # 每页候选词
        PageSize=7
        # 显示英文候选词
        SpellEnabled=True
        # 显示符号候选词
        SymbolsEnabled=True
        # 显示拆字候选词
        ChaiziEnabled=True
        # 启用 Unicode CJK 拓展区 B 之后的更多字符
        ExtBEnabled=True
        # 输入 h(横)，s(竖)，p(撇)，n(捺)，z(折) 时显示笔画候选词
        StrokeCandidateEnabled=True
        # 启用云拼音
        CloudPinyinEnabled=False
        # 云拼音候选词顺序
        CloudPinyinIndex=2
        # 加载云拼音的时候显示动画
        CloudPinyinAnimation=True
        # 总是显示云拼音的占位符
        KeepCloudPinyinPlaceHolder=False
        # 预编辑模式
        PreeditMode="Composing pinyin"
        # 将嵌入预编辑文本的光标固定在开头
        PreeditCursorPositionAtBeginning=True
        # 在预编辑中显示完整拼音
        PinyinInPreedit=False
        # 启用预测
        Prediction=False
        # 为下次输入预测保留当前输入的文本
        KeepCurrentContext=True
        # 预测数量
        PredictionSize=49
        # 预测时退格键的行为
        BackspaceBehaviorOnPrediction="Backspace when not using on-screen keyboard"
        # 切换输入法时的行为
        SwitchInputMethodBehavior="Commit current preedit"
        # 选择第二个候选词
        SecondCandidate=
        # 选择第三个候选词
        ThirdCandidate=
        # 使用数字键盘选词
        UseKeypadAsSelection=False
        # 使用退格键取消选词
        BackSpaceToUnselect=True
        # 句子数量
        Number of sentence=2
        # 词组候选词数
        WordCandidateLimit=15
        # 输入长于...时提示长词 (设置为 0 时禁用)
        LongWordLengthLimit=4
        # 快速输入的触发键
        QuickPhraseKey=semicolon
        # 使用 V 来触发快速输入
        VAsQuickphrase=True
        # FirstRun
        FirstRun=False

        [ForgetWord]
        0=Control+7

        [PrevPage]
        0=minus
        1=Up
        2=KP_Up
        3=Page_Up

        [NextPage]
        0=equal
        1=Down
        2=KP_Down
        3=Next

        [PrevCandidate]
        0=Shift+Tab

        [NextCandidate]
        0=Tab

        [CurrentCandidate]
        0=space
        1=KP_Space

        [CommitRawInput]
        0=Return
        1=KP_Enter
        2=Control+Return
        3=Control+KP_Enter
        4=Shift+Return
        5=Shift+KP_Enter
        6=Control+Shift+Return
        7=Control+Shift+KP_Enter

        [ChooseCharFromPhrase]
        0=bracketleft
        1=bracketright

        [FilterByStroke]
        0=grave

        [QuickPhraseTriggerRegex]
        0=.(/|@)$
        1="^(www|bbs|forum|mail|bbs)\\\\."
        2=^(http|https|ftp|telnet|mailto):

        [Fuzzy]
        # ue -> ve
        VE_UE=True
        # 常见错误
        NG_GN=True
        # 内模糊音节 (xian -> xi'an)
        Inner=True
        # 短拼音的内模糊音节 (qie -> qi'e)
        InnerShort=True
        # 匹配不完整的元音 (e -> en, eng, ei)
        PartialFinal=True
        # 输入长度大于 4 时进行部分双拼匹配
        PartialSp=False
        # u <-> v
        V_U=False
        # an <-> ang
        AN_ANG=False
        # en <-> eng
        EN_ENG=False
        # ian <-> iang
        IAN_IANG=False
        # in <-> ing
        IN_ING=False
        # u <-> ou
        U_OU=False
        # uan <-> uang
        UAN_UANG=False
        # c <-> ch
        C_CH=False
        # f <-> h
        F_H=False
        # l <-> n
        L_N=False
        # l <-> r
        L_R=False
        # s <-> sh
        S_SH=False
        # z <-> zh
        Z_ZH=False
        # 纠错布局
        Correction=None
      '';
    };
  };
}
