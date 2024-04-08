# dotfiles

This repository holds my Linux config files.

## Mandatory unixporn screenshots

## Tools

| Purpose          | Tool                                                                   |
| ---------------- | ---------------------------------------------------------------------- |
| bar              | polybar                                                                |
| App launcher     | rofi                                                                   |
| Shell            | Bash                                                                   |
| Package managers | Pacman & Trizen                                                        |
| OS               | Arch Linux                                                             |
| Terminal         | xfce4-terminal                                                         |
| Editor           | nano                                                                   |
| Code editor      | vscode                                                                 |
| Browser          | Firefox                                                                |
| File manager     | If I have to use one ... Thunar                                        |
| Music            | Tidal through [Tidal-hifi](https://github.com/Mastermindzh/tidal-hifi) |

## computer specifc setup

Nowadays I use a few different computers and I used to apply the base config and configure each pc on its own.
I've grown tired of this approach however so I added a "pc specific" setup in the installer.

The pc specific setup bit will read the folder names in computers, offer you a choice, and execute the install.sh inside that folder.
This allows me to get pc specific settings synced with git and applied easily.

## Getting x info to use in i3

Some things are handled by window class/title or have custom resolutions set, the tools below help obtain the info required:

- xprop -> displays static xwindow info including Window class
- xwininfo -> displays xwindow info including current size/position

## getting icons

Copy/paste icons from these URLs:

- [https://fonts.google.com/noto/specimen/Noto+Color+Emoji/glyphs?noto.query=noto+color+emoji](https://fonts.google.com/noto/specimen/Noto+Color+Emoji/glyphs?noto.query=noto+color+emoji)

## after-install

After install read [./docs/afterinstall.md](./docs/afterinstall.md)
