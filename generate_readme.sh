#!/bin/bash

# Ensure output directory for screenshots exists
mkdir -p screenshots

# Read configuration from JSON (requires 'jq' or similar JSON parser)
# Install jq: sudo apt-get install jq
CONFIG_FILE="config.json"

# --- Start building README.md ---
echo "# $(jq -r .project_title "$CONFIG_FILE")" > README.md
echo "## $(jq -r .project_tagline "$CONFIG_FILE")" >> README.md
echo "" >> README.md
echo "---" >> README.md
echo "" >> README.md

# --- Generate Table of Contents (Manual entry for now, or script dynamically) ---
echo "### 📚 Table of Contents" >> README.md
echo "* [About Me](#about-me)" >> README.md
echo "* [What I Offer](#what-i-offer)" >> README.md
# ... add other static TOC entries
echo "* [🚀 The Proof: From 2 Words to Full Content Strategy!](#the-proof-from-2-words-to-full-content-strategy)" >> README.md
echo "    * [Phase 1: Initial Idea & Script Generation](#phase-1-initial-idea--script-generation-)" >> README.md
# ... add other phase TOC entries dynamically from JSON
echo "* [A Final Note](#a-final-note)" >> README.md
echo "" >> README.md
echo "---" >> README.md
echo "" >> README.md


# --- Append static sections (from MD files) ---
echo "<a name=\"about-me\"></a>" >> README.md
echo "### About Me" >> README.md
cat "$(jq -r .about_me_text_file "$CONFIG_FILE")" >> README.md
echo "" >> README.md # Add newline

echo "<a name=\"what-i-offer\"></a>" >> README.md
echo "### What I Offer" >> README.md
cat "$(jq -r .what_i_offer_text_file "$CONFIG_FILE")" >> README.md
echo "" >> README.md # Add newline

# ... Repeat for other static sections

# --- Case Study Section ---
echo "<a name=\"the-proof-from-2-words-to-full-content-strategy\"></a>" >> README.md
echo "## 🚀 $(jq -r .case_study.title "$CONFIG_FILE")" >> README.md
echo "$(jq -r .case_study.description "$CONFIG_FILE")" >> README.md
echo "" >> README.md

# Loop through phases in case study
jq -c '.case_study.phases[]' "$CONFIG_FILE" | while read -r phase_json; do
    PHASE_ID=$(echo "$phase_json" | jq -r .id)
    PHASE_TITLE=$(echo "$phase_json" | jq -r .title)
    TRANSCRIPT_FILE=$(echo "$phase_json" | jq -r .transcript_file)

    echo "<a name=\"$(echo "$PHASE_TITLE" | sed 's/[^a-zA-Z0-9]//g' | tr '[:upper:]' '[:lower:]')\"></a>" >> README.md
    echo "### $(echo "$PHASE_TITLE")" >> README.md
    echo "" >> README.md
    cat "$TRANSCRIPT_FILE" >> README.md
    echo "" >> README.md

    # Loop through screenshots for each phase
    echo "$phase_json" | jq -c '.screenshots[]' | while read -r screenshot_json; do
        IMG_FILE=$(echo "$screenshot_json" | jq -r .file)
        IMG_ALT=$(echo "$screenshot_json" | jq -r .alt)
        echo "![${IMG_ALT}](.${IMG_FILE})" >> README.md # "./" for relative path
        echo "" >> README.md
    done
    echo "" >> README.md # Add newline after each phase
done

# --- Append Final Note section ---
echo "<a name=\"a-final-note\"></a>" >> README.md
echo "### A Final Note" >> README.md
cat "$(jq -r .final_note_text_file "$CONFIG_FILE")" >> README.md
echo "" >> README.md

echo "README.md generated successfully!"
