# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Network Proxy

**Shadowrocket 代理**: 127.0.0.1:7897 (HTTP/SOCKS5)

curl/gh 等 CLI 默认不走代理，需要加参数：
```bash
curl -x "http://127.0.0.1:7897" https://...
gh api ...  # 需要 set proxy env
```

浏览器工具自动走系统代理，不需要额外配置。

**解决方案**：OpenClaw exec 的默认 shell 环境没有继承系统代理变量，后续调用 curl/gh 时需要显式加 `-x` 参数，或者在 shell 配置文件(~/.zshrc)里设置环境变量。
