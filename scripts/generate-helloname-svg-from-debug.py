#!/usr/bin/env python3
import argparse
import re
import subprocess
from pathlib import Path


def run_replay(repo_root: Path) -> str:
    p = subprocess.run(
        [str(repo_root / "scripts" / "aivectra"), "run", str(repo_root / "samples" / "HelloName"), "replay"],
        capture_output=True,
        text=True,
        check=True,
    )
    return p.stdout


def parse(replay: str):
    layout = re.search(r"layout panel=(\d+),(\d+),(\d+),(\d+) input=(\d+),(\d+),(\d+),(\d+) button=(\d+),(\d+),(\d+),(\d+)", replay)
    if not layout:
        raise SystemExit("Could not parse layout line from replay output")
    panel = tuple(map(int, layout.groups()[0:4]))
    input_rect = tuple(map(int, layout.groups()[4:8]))
    button_rect = tuple(map(int, layout.groups()[8:12]))

    greeting = re.search(r"replay greeting=(.*)", replay)
    greeting_text = greeting.group(1).strip() if greeting else "Greeting: (unknown)"

    name = "todd"
    if "replay backspace=ted" in replay:
        name = "todd"

    return panel, input_rect, button_rect, name, greeting_text


def build_svg(panel, input_rect, button_rect, name, greeting_text):
    px, py, pw, ph = panel
    ix, iy, iw, ih = input_rect
    bx, by, bw, bh = button_rect

    w = px + pw + 20
    h = py + ph + 20

    button_text_x = bx + bw // 2
    button_text_y = by + (bh // 2) + 8

    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#1e293b"/>
      <stop offset="50%" stop-color="#334155"/>
      <stop offset="100%" stop-color="#1e293b"/>
    </linearGradient>
    <linearGradient id="field" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#172554"/>
      <stop offset="100%" stop-color="#0f172a"/>
    </linearGradient>
    <linearGradient id="btn" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#2563eb"/>
      <stop offset="100%" stop-color="#3b82f6"/>
    </linearGradient>
  </defs>

  <rect x="0" y="0" width="{w}" height="{h}" fill="#0f172a"/>
  <rect x="{px}" y="{py}" width="{pw}" height="{ph}" fill="url(#bg)"/>

  <text x="72" y="72" fill="#ffffff" font-size="28" font-family="monospace">Enter your name</text>

  <rect x="{ix}" y="{iy}" width="{iw}" height="{ih}" fill="url(#field)"/>
  <text x="{ix + 16}" y="{iy + 33}" fill="#ffffff" font-size="24" font-family="monospace">{name}</text>

  <rect x="{bx}" y="{by}" width="{bw}" height="{bh}" fill="url(#btn)"/>
  <text x="{button_text_x}" y="{button_text_y}" text-anchor="middle" fill="#ffffff" font-size="22" font-family="monospace">Submit</text>

  <text x="72" y="522" fill="#cbd5e1" font-size="15" font-family="monospace">Type to edit. Enter submits.</text>
  <text x="72" y="544" fill="#cbd5e1" font-size="15" font-family="monospace">Backspace/Delete edits text.</text>
  <text x="72" y="568" fill="#ffffff" font-size="18" font-family="monospace">{greeting_text}</text>
</svg>
'''


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="samples/HelloName/Assets/hello_name.debug.svg")
    args = ap.parse_args()

    repo_root = Path(__file__).resolve().parents[1]
    replay = run_replay(repo_root)
    panel, input_rect, button_rect, name, greeting = parse(replay)

    svg = build_svg(panel, input_rect, button_rect, name, greeting)
    out = repo_root / args.out
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(svg, encoding="utf-8")

    print(str(out))


if __name__ == "__main__":
    main()
