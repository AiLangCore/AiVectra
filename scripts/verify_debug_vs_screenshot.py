#!/usr/bin/env python3
import argparse
import os
import re
import subprocess
import sys
from typing import Tuple


def run(cmd):
    p = subprocess.run(cmd, capture_output=True, text=True)
    if p.returncode != 0:
        raise RuntimeError(f"command failed: {' '.join(cmd)}\n{p.stderr}")
    return p.stdout


def parse_layout(line: str):
    m_in = re.search(r"input=(\d+),(\d+),(\d+),(\d+)", line)
    m_btn = re.search(r"button=(\d+),(\d+),(\d+),(\d+)", line)
    if not m_in or not m_btn:
        raise ValueError(f"unable to parse layout line: {line}")
    ix, iy, iw, ih = map(int, m_in.groups())
    bx, by, bw, bh = map(int, m_btn.groups())
    return (ix, iy, iw, ih), (bx, by, bw, bh)


def parse_rgb_from_hex(hexv: str) -> Tuple[int, int, int]:
    hexv = hexv.lstrip("#")
    if len(hexv) < 6:
        raise ValueError(f"bad hex color: {hexv}")
    return int(hexv[0:2], 16), int(hexv[2:4], 16), int(hexv[4:6], 16)


def color_close(a, b, tol=24):
    return all(abs(x - y) <= tol for x, y in zip(a, b))


def parse_pixel(text: str) -> Tuple[int, int, int]:
    text = text.strip()
    m = re.search(r"#([0-9A-Fa-f]{6})", text)
    if m:
        return parse_rgb_from_hex("#" + m.group(1))
    m = re.search(r"srgb\((\d+),(\d+),(\d+)\)", text)
    if m:
        return tuple(map(int, m.groups()))
    m = re.search(r"rgba\((\d+),(\d+),(\d+),", text)
    if m:
        return tuple(map(int, m.groups()))
    raise ValueError(f"unrecognized pixel format: {text}")


def sample_pixel(image_path: str, x: int, y: int) -> Tuple[int, int, int]:
    out = run(["magick", image_path, "-format", f"%[pixel:p{{{x},{y}}}]", "info:"])
    return parse_pixel(out)


def extract_dimensions(txt_header: str):
    m = re.search(r"pixel enumeration:\s*(\d+),(\d+),", txt_header)
    if not m:
        m = re.search(r"(\d+),(\d+):", txt_header)
    if not m:
        raise ValueError("could not parse image dimensions")
    return int(m.group(1)), int(m.group(2))


def detect_input_rect(image_path: str):
    # Focused text field color in HelloName renderer.
    target = parse_rgb_from_hex("#172554")

    proc = subprocess.Popen(["magick", image_path, "txt:-"], stdout=subprocess.PIPE, text=True)
    if not proc.stdout:
        raise RuntimeError("failed to read image pixel stream")

    header = proc.stdout.readline().strip()
    if "pixel enumeration" not in header:
        # Skip until we find the ImageMagick header line.
        while header and "pixel enumeration" not in header:
            header = proc.stdout.readline().strip()
    width_m1, height_m1 = extract_dimensions(header)

    min_x = None
    min_y = None
    row_points = {}

    for line in proc.stdout:
        m = re.match(r"\s*(\d+),(\d+):\s*\([^)]*\)\s*(#[0-9A-Fa-f]{6})", line)
        if not m:
            continue
        x, y, hx = int(m.group(1)), int(m.group(2)), m.group(3)
        rgb = parse_rgb_from_hex(hx)
        if color_close(rgb, target, tol=18):
            if min_x is None or x < min_x:
                min_x = x
            if min_y is None or y < min_y:
                min_y = y
            row_points.setdefault(y, [x, x])
            row_points[y][0] = min(row_points[y][0], x)
            row_points[y][1] = max(row_points[y][1], x)

    proc.wait()
    if proc.returncode != 0:
        raise RuntimeError("magick txt parse failed")

    if min_x is None or min_y is None:
        raise RuntimeError("could not detect focused input field color in screenshot")

    # Choose widest matching row near top as input row.
    top_rows = sorted(y for y in row_points.keys() if y >= min_y and y <= min_y + 40)
    if not top_rows:
        top_rows = [min_y]
    best_y = top_rows[0]
    best_w = -1
    for y in top_rows:
        x0, x1 = row_points[y]
        w = x1 - x0 + 1
        if w > best_w:
            best_w = w
            best_y = y

    x0, x1 = row_points[best_y]
    return {
        "image_w": width_m1 + 1,
        "image_h": height_m1 + 1,
        "input_x": x0,
        "input_y": best_y,
        "input_w": x1 - x0 + 1,
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--image", required=True)
    ap.add_argument("--layout-line", required=True)
    args = ap.parse_args()

    input_rect, button_rect = parse_layout(args.layout_line)
    ix, iy, iw, ih = input_rect
    bx, by, bw, bh = button_rect

    detect = detect_input_rect(args.image)

    # Infer scale from detected width.
    scale = max(1, round(detect["input_w"] / float(iw)))
    origin_x = detect["input_x"] - ix * scale
    origin_y = detect["input_y"] - iy * scale

    # Probe representative pixels.
    input_probe = (
        origin_x + (ix + 12) * scale,
        origin_y + (iy + ih // 2) * scale,
    )
    button_probe = (
        origin_x + (bx + (bw // 2)) * scale,
        origin_y + (by + (bh // 2)) * scale,
    )

    input_rgb = sample_pixel(args.image, *input_probe)
    button_rgb = sample_pixel(args.image, *button_probe)

    expected_input = parse_rgb_from_hex("#172554")
    ok_input = color_close(input_rgb, expected_input, tol=34)
    ok_button = (
        button_rgb[2] >= button_rgb[0] + 20
        and button_rgb[2] >= button_rgb[1] + 12
        and button_rgb[2] >= 80
    )

    print("[[aivectra.verify]]")
    print(f"scale={scale}")
    print(f"origin=\"{origin_x},{origin_y}\"")
    print(f"input_probe=\"{input_probe[0]},{input_probe[1]}\"")
    print(f"input_rgb=\"{input_rgb[0]},{input_rgb[1]},{input_rgb[2]}\"")
    print(f"button_probe=\"{button_probe[0]},{button_probe[1]}\"")
    print(f"button_rgb=\"{button_rgb[0]},{button_rgb[1]},{button_rgb[2]}\"")

    if not ok_input:
        print("input probe color does not match expected text field color", file=sys.stderr)
        sys.exit(3)
    if not ok_button:
        print("button probe color is not blue-dominant as expected for the submit button", file=sys.stderr)
        sys.exit(4)


if __name__ == "__main__":
    main()
