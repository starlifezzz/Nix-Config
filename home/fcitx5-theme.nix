# modules/fcitx5-theme.nix
{ lib, ... }:

let
  mkFcitx5Theme = name: body: {
    "fcitx5/themes/${name}/theme.conf".text = body;
  };
in
{
  xdg.dataFile = lib.mkMerge [
    (mkFcitx5Theme "macos-light" ''
      [Metadata]
      Name=macOS Light
      Version=1
      Author=一方 (ported)

      [InputPanel]
      Font=Noto Sans CJK SC 17
      NormalColor=#424242ff
      HighlightCandidateColor=#ffffffff
      HighlightBackgroundColor=#005ad7ff
      CandidateColor=#3c3c3cff
      CommentColor=#999999ff
      LabelColor=#999999ff
      BorderColor=#ffffffff
      BackgroundColor=#ffffffff
      MarginLeft=4
      MarginRight=4
      MarginTop=4
      MarginBottom=4
      Spacing=4
      BorderRadius=5
      Layout=Horizontal

      [Preedit]
      Mode=Composed
    '')

    # 以后加新主题直接追加
    # (mkFcitx5Theme "another-theme" ''...'')
  ];
}