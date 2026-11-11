"""Patch /handler.py (worker-comfyui 5.10.0) so video outputs are returned.

The stock handler only collects the "images" key from each node's history
output. VHS_VideoCombine results arrive under "gifs" (some versions also
use "videos") with the same {filename, subfolder, type} shape, and were
dropped with an "unhandled output keys" warning (a job ended with status
success_no_images on 2026-11-11 and the video was lost). Merge those keys
into "images" right after the per-node loop starts; everything downstream
(fetch via /view, base64 return) then works unchanged.
"""

import sys

PATH = "/handler.py"

with open(PATH) as f:
    lines = f.read().split("\n")

target = None
for i, ln in enumerate(lines):
    if ln.strip() == "for node_id, node_output in outputs.items():":
        target = i
        break

if target is None:
    sys.exit("PATCH FAILED: anchor line not found in /handler.py")

indent = lines[target][: len(lines[target]) - len(lines[target].lstrip())] + "    "
patch = [
    indent + 'for _vk in ("gifs", "videos"):',
    indent + "    if _vk in node_output:",
    indent + '        node_output.setdefault("images", []).extend(node_output.pop(_vk))',
]
lines[target + 1 : target + 1] = patch

with open(PATH, "w") as f:
    f.write("\n".join(lines))

print("handler.py patched: gifs/videos merged into images")
