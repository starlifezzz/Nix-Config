# ═══════════════════════════════════════════════════════════
# 🎵 MPD DSD 播放配置（可选）
# ═══════════════════════════════════════════════════════════
# 用途：配置 MPD 支持 DSD 硬件直解
# 用法：在 home.nix 中导入此模块
# ═══════════════════════════════════════════════════════════

{ config, pkgs, ... }:

{
  # 启用 MPD 服务
  services.mpd = {
    enable = true;
    
    # 使用支持 DSD 的 MPD 版本
    package = pkgs.mpd;
    
    # 音乐库目录
    musicDirectory = config.home.homeDirectory + "/nas/Music";
    
    # 播放列表目录
    playlistDirectory = config.home.homeDirectory + "/nas/Music/Playlists";
    
    # MPD 配置文件
    extraConfig = ''
      # ═══════════════════════════════════════════════════════
      # 🔊 音频输出配置 - FIIO K5 Pro DSD 硬解
      # ═══════════════════════════════════════════════════════
      audio_output {
        type            "alsa"
        name            "FIIO K5 Pro"
        device          "hw:Pro,0"    # 直接使用硬件设备
        mixer_type      "software"      # 软件混音
        auto_resample   "no"            # 禁用自动重采样
        dsd_usb         "yes"           # 启用 DSD over USB (DoP)
      }
      
      # 备用输出（普通 PCM）
      audio_output {
        type            "alsa"
        name            "FIIO K5 Pro (PCM Only)"
        device          "hw:Pro,0"
        mixer_type      "software"
      }
      
      # ═══════════════════════════════════════════════════════
      # 音频解码器配置
      # ═══════════════════════════════════════════════════════
      
      # DSD 文件支持 (.dsf, .dff)
      decoder {
        plugin          "dsf"
        enabled         "yes"
      }
      
      # SACD ISO 支持（需要外部库）
      # decoder {
      #   plugin        "sacd"
      #   enabled       "yes"
      #   input_types   "iso"
      # }
      
      # ═══════════════════════════════════════════════════════
      # 音频处理优化
      # ═══════════════════════════════════════════════════════
      
      # 音量归一化（可选）
      volume_normalization    "no"
      
      # 回放增益（推荐启用）
      replaygain              "album"
      replaygain_preamp       "0"
      replaygain_limit        "true"
      
      # 音频格式限制（根据 DAC 能力）
      # max_output_format {
      #   sample_rate         "384000"
      #   bits                "32"
      # }
      
      # ═══════════════════════════════════════════════════════
      # 其他必要配置
      # ═══════════════════════════════════════════════════════
      
      # 网络接口
      bind_to_address       "localhost"
      bind_to_address       "@/tmp/mpd.socket"
      
      # 端口
      port                  "6600"
      
      # 日志 - 使用 systemd journal（推荐）
      log_file              "syslog"
      
      # 数据库
      db_file               "~/.local/state/mpd/database.db"
      
      # 状态文件（记住播放位置）
      state_file            "~/.local/state/mpd/state"
      
      # 贴纸支持（歌曲评分等）
      sticker_file          "~/.local/state/mpd/sticker.sql"
    '';
  };
  
  # 安装 MPD 客户端工具
  home.packages = with pkgs; [
    mpc      # 命令行客户端（原 mpc-cli）
    ncmpcpp  # 高级终端客户端（支持 DSD 显示）
  ];
}