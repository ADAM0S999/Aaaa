#!/usr/bin/env bash
set -euo pipefail

# Simple generator script for AUTOMATIC1111 sdapi (Stable Diffusion web UI)
# Saves 3 images (brochettes, frites, wrap) into the `images/` folder.
# Usage:
#   1) Ensure AUTOMATIC1111 Web UI is running (default: http://127.0.0.1:7860)
#   2) Install dependencies: jq, curl, base64 (coreutils)
#      On Ubuntu: sudo apt update && sudo apt install -y jq curl
#   3) Run: bash scripts/generate_images.sh

SDAPI_URL="${SDAPI_URL:-http://127.0.0.1:7860}"
OUTDIR="${OUTDIR:-images}"
mkdir -p "$OUTDIR"

generate() {
  local fname="$1"
  local prompt="$2"
  local negative="$3"
  local width=${4:-768}
  local height=${5:-960}
  local steps=${6:-28}
  local sampler="${7:-Euler a}"
  local cfg=${8:-7.0}
  local seed=${9:--1}

  echo "Generating $fname ..."

  resp=$(curl -s -X POST "$SDAPI_URL/sdapi/v1/txt2img" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg p "$prompt" --arg np "$negative" --argjson w "$width" --argjson h "$height" --arg s "$sampler" --argjson steps "$steps" --argjson cfg "$cfg" --argjson seed "$seed" '{prompt:$p,negative_prompt:$np,width:$w,height:$h,sampler_name:$s,steps:$steps,cfg_scale:$cfg,seed:$seed,n:1}')")

  img_b64=$(echo "$resp" | jq -r '.images[0] // empty')
  if [ -z "$img_b64" ]; then
    echo "ERROR: no image generated. Response:"
    echo "$resp"
    return 1
  fi

  echo "$img_b64" | base64 --decode > "$OUTDIR/$fname"
  echo "Saved $OUTDIR/$fname"
}

# Prompts (from ai_prompts_food_photos.md)
BROCHETTES_PROMPT="Close-up of perfectly grilled chicken and beef brochettes on a matte black plate, glistening with olive oil, sprinkled with chopped parsley and sesame, small lemon wedge and a ramekin of harissa sauce on the side, clean pale background, warm natural studio lighting, shallow depth of field, 45-degree angle, highly detailed, appetizing food photography, warm color palette (gold orange red)"
BROCHETTES_NEG="blurry, hands-only, extra limbs, text, watermark, lowres, oversaturated skin tones, unnatural colors"

FRITES_PROMPT="Portion of crispy golden fries served on a matte black plate, sprinkled with sea salt and chopped parsley, small dipping sauce, a hand about to pick a fry, clean pale background, warm cozy lighting, overhead 30% / 45% angle, high detail, appetizing texture"
FRITES_NEG="motion blur, out of focus, greasy sheen unrealistic, text, logo, watermark"

WRAP_PROMPT="Fresh wrap cut in half on a matte black plate, juicy grilled meat, colorful salad, pickles, tahini drizzle visible, close 45-degree shot, clean light background, warm studio light, shallow depth of field, vibrant but natural colors, modern street-food aesthetic"
WRAP_NEG="oversharpened, CGI, low detail, watermark, text"

# Generate images
generate "brochettes.png" "$BROCHETTES_PROMPT" "$BROCHETTES_NEG" 768 960 28 "Euler a" 7.0 -1
generate "frites.png" "$FRITES_PROMPT" "$FRITES_NEG" 768 960 24 "DDIM" 6.5 -1
generate "wrap.png" "$WRAP_PROMPT" "$WRAP_NEG" 768 960 28 "K_lms" 7.0 -1

echo "All done. Images saved in $OUTDIR/"
