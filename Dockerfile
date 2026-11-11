# MiniMax H3 (ref2va) worker for RunPod Serverless
# Base: official RunPod ComfyUI worker (ComfyUI 0.34.0, handler included).
# Custom nodes are pinned to the exact commits validated on the Pod.
# Models stay on the network volume.
FROM runpod/worker-comfyui:5.10.0-base

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

# --- model folders: point ComfyUI's built-in model dirs at the network volume ---
# The base worker's volume mapping does not cover every folder type this
# workflow needs (text_encoders and latent_upscale_models stayed invisible,
# which failed workflow validation on 2026-11-11). Symlink every model type
# dir to the volume so all of them resolve under /runpod-volume/models/<type>.
RUN for t in audio_encoders background_removal checkpoints clip clip_vision configs controlnet detection diffusion_models diffusers embeddings frame_interpolation geometry_estimation gligen hypernetworks latent_upscale_models loras model_patches motion_models optical_flow other photomaker poses style_models text_encoders unet upscale_models vae vae_approx wildcards; do \
      rm -rf "/comfyui/models/$t"; \
      ln -s "/runpod-volume/models/$t" "/comfyui/models/$t"; \
    done

WORKDIR /comfyui
# Handler/CMD are inherited from the base worker image.
