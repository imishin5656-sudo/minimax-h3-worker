# MiniMax H3 (ref2va) worker for RunPod Serverless
# Base: official RunPod ComfyUI worker (ComfyUI 0.34.0, handler included).
# Custom nodes are pinned to the exact commits validated on the Pod.
# Models stay on the network volume.
FROM runpod/worker-comfyui:5.11.0-base

WORKDIR /comfyui/custom_nodes

RUN git clone https://github.com/rgthree/rgthree-comfy.git rgthree-comfy && \
    cd rgthree-comfy && git checkout bc48c6a
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git ComfyUI-VideoHelperSuite && \
    cd ComfyUI-VideoHelperSuite && git checkout 4d907be
RUN git clone https://github.com/yolain/ComfyUI-Easy-Use.git ComfyUI-Easy-Use && \
    cd ComfyUI-Easy-Use && git checkout b0b47ca
RUN git clone https://github.com/r-vage/ComfyUI-sol-attn.git ComfyUI-sol-attn && \
    cd ComfyUI-sol-attn && git checkout 69d2e40
RUN git clone https://github.com/LBH-123-AI/Comfyui_Minimax_h3_latent_Upscaler.git ComfyUI_Minimax_h3_latent_Upscaler && \
    cd ComfyUI_Minimax_h3_latent_Upscaler && git checkout f34cadb

RUN for f in /comfyui/custom_nodes/*/requirements.txt; do \
      if [ -f "$f" ]; then python3 -m pip install --no-cache-dir -r "$f" || exit 1; fi; \
    done

WORKDIR /comfyui
