#!/usr/bin/env python3
import argparse
import html
import re
import subprocess
from collections import defaultdict
from pathlib import Path
from typing import Optional

FRAME_RE = re.compile(r'aivectra\.frame = \{ id=(\d+), width=(\d+), height=(\d+), hash="([^"]*)" \}')
NODE_RE = re.compile(
    r'aivectra\.node = \{ frame=(\d+), order=(\d+), id="([^"]*)", parent="([^"]*)", kind="([^"]*)", transform="([^"]*)", fill="([^"]*)", stroke="([^"]*)", stroke_width=(\d+), text="([^"]*)", path="([^"]*)", font_size=(\d+), x=(-?\d+), y=(-?\d+), w=(-?\d+), h=(-?\d+) \}'
)
END_RE = re.compile(r'aivectra\.frame_end = \{ id=(\d+), node_count=(\d+) \}')


def run_scene(repo: Path) -> str:
    p = subprocess.run(
        [str(repo / "scripts" / "aivectra"), "run", str(repo / "samples" / "HelloName"), "scene"],
        capture_output=True,
        text=True,
        check=True,
    )
    return p.stdout


def parse(debug_text: str, frame_id: Optional[int]):
    frames = {}
    nodes_by_frame = defaultdict(list)
    frame_ends = {}
    for line in debug_text.splitlines():
        line = line.strip()
        if not line:
            continue
        m = FRAME_RE.match(line)
        if m:
            fid = int(m.group(1))
            frames[fid] = {
                "id": int(m.group(1)),
                "width": int(m.group(2)),
                "height": int(m.group(3)),
                "hash": m.group(4),
            }
            continue
        m = NODE_RE.match(line)
        if m:
            fid = int(m.group(1))
            nodes_by_frame[fid].append(
                {
                    "frame": fid,
                    "order": int(m.group(2)),
                    "id": m.group(3),
                    "parent": m.group(4),
                    "kind": m.group(5),
                    "transform": m.group(6),
                    "fill": m.group(7),
                    "stroke": m.group(8),
                    "stroke_width": int(m.group(9)),
                    "text": m.group(10),
                    "path": m.group(11),
                    "font_size": int(m.group(12)),
                    "x": int(m.group(13)),
                    "y": int(m.group(14)),
                    "w": int(m.group(15)),
                    "h": int(m.group(16)),
                }
            )
            continue
        m = END_RE.match(line)
        if m:
            frame_ends[int(m.group(1))] = {"id": int(m.group(1)), "node_count": int(m.group(2))}

    if not frames:
        raise SystemExit("MISSING DEBUG DATA REPORT\n- Missing: frame header")

    if frame_id is None:
        chosen = sorted(frames.keys())[0]
    else:
        chosen = frame_id

    if chosen not in frames:
        raise SystemExit(f"MISSING DEBUG DATA REPORT\n- Missing requested frame id={chosen}")
    if chosen not in nodes_by_frame:
        raise SystemExit(f"MISSING DEBUG DATA REPORT\n- Missing node records for frame id={chosen}")
    if chosen not in frame_ends:
        raise SystemExit(f"MISSING DEBUG DATA REPORT\n- Missing frame_end for frame id={chosen}")

    frame = frames[chosen]
    nodes = nodes_by_frame[chosen]
    end = frame_ends[chosen]
    if end["node_count"] != len(nodes):
        raise SystemExit(
            f"MISSING DEBUG DATA REPORT\n- node_count mismatch: frame_end={end['node_count']} parsed={len(nodes)}"
        )

    nodes.sort(key=lambda n: n["order"])
    return frame, nodes


def attrs_common(n):
    out = []
    if n["fill"]:
        out.append(f'fill="{html.escape(n["fill"], quote=True)}"')
    else:
        out.append('fill="none"')
    if n["stroke"]:
        out.append(f'stroke="{html.escape(n["stroke"], quote=True)}"')
    if n["stroke_width"] > 0:
        out.append(f'stroke-width="{n["stroke_width"]}"')
    if n["transform"] and n["transform"] != "matrix(1,0,0,1,0,0)":
        out.append(f'transform="{html.escape(n["transform"], quote=True)}"')
    return " ".join(out)


def render_node(n, children_by_parent, by_id, indent=2):
    pad = " " * indent
    kid_ids = children_by_parent.get(n["id"], [])
    if n["kind"] == "Group":
        attr = attrs_common(n)
        lines = [f'{pad}<g id="{html.escape(n["id"], quote=True)}" {attr}>'.rstrip()]
        for cid in kid_ids:
            lines.extend(render_node(by_id[cid], children_by_parent, by_id, indent + 2))
        lines.append(f"{pad}</g>")
        return lines

    attr = attrs_common(n)
    if n["kind"] == "Rect":
        return [f'{pad}<rect id="{html.escape(n["id"], quote=True)}" x="{n["x"]}" y="{n["y"]}" width="{n["w"]}" height="{n["h"]}" {attr}/>'.rstrip()]
    if n["kind"] == "Ellipse":
        cx = n["x"] + (n["w"] // 2)
        cy = n["y"] + (n["h"] // 2)
        rx = max(0, n["w"] // 2)
        ry = max(0, n["h"] // 2)
        return [f'{pad}<ellipse id="{html.escape(n["id"], quote=True)}" cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" {attr}/>'.rstrip()]
    if n["kind"] == "Path":
        d = html.escape(n["path"], quote=True)
        return [f'{pad}<path id="{html.escape(n["id"], quote=True)}" d="{d}" {attr}/>'.rstrip()]
    if n["kind"] == "Text":
        t = html.escape(n["text"])
        font = ""
        if n["font_size"] > 0:
            font = f' font-size="{n["font_size"]}"'
        return [f'{pad}<text id="{html.escape(n["id"], quote=True)}" x="{n["x"]}" y="{n["y"]}"{font} font-family="monospace" {attr}>{t}</text>'.rstrip()]
    return [f'{pad}<!-- unsupported kind {html.escape(n["kind"])} -->']


def build_svg(frame, nodes):
    by_id = {n["id"]: n for n in nodes}
    children_by_parent = defaultdict(list)
    for n in nodes:
        parent = n["parent"]
        if parent:
            children_by_parent[parent].append(n["id"])
    for pid in list(children_by_parent.keys()):
        children_by_parent[pid].sort(key=lambda cid: by_id[cid]["order"])

    roots = [n for n in nodes if not n["parent"]]
    roots.sort(key=lambda n: n["order"])

    lines = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{frame["width"]}" height="{frame["height"]}" viewBox="0 0 {frame["width"]} {frame["height"]}">',
        f'  <metadata>scene_hash={html.escape(frame["hash"])}</metadata>',
    ]
    for r in roots:
        lines.extend(render_node(r, children_by_parent, by_id, indent=2))
    lines.append("</svg>")
    return "\n".join(lines) + "\n"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="artifacts/debug_render.svg")
    ap.add_argument("--input-log", default="")
    ap.add_argument("--frame-id", type=int, default=0)
    args = ap.parse_args()

    repo = Path(__file__).resolve().parents[1]
    if args.input_log:
        debug_text = Path(args.input_log).read_text(encoding="utf-8")
    else:
        debug_text = run_scene(repo)
    chosen = args.frame_id if args.frame_id > 0 else None
    frame, nodes = parse(debug_text, chosen)
    svg = build_svg(frame, nodes)

    out_path = repo / args.out
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(svg, encoding="utf-8")

    print(str(out_path))


if __name__ == "__main__":
    main()
