# /etc/nixos/modules/services/audio.nix
# 音频与多媒体服务 (PipeWire, RTKit, UPower)
# 官方文档：
#   https://nixos.org/manual/nixos/unstable/options.html#opt-services.pipewire.enable
#   https://nixos.org/manual/nixos/unstable/options.html#opt-services.upower.enable
{ ... }:

{
  # PulseAudio 禁用 - 使用 PipeWire 替代
  services.pulseaudio.enable = false;

  # RTKit - 实时音频/视频优先级
  security.rtkit.enable = true;

  # PipeWire - 音频和视频流处理（支持 DSD 硬解）
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = false; # 禁用 jack 避免 LD_LIBRARY_PATH 冲突
  };

}