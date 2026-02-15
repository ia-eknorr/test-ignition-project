#!/bin/bash
set -e

seed_gateway() {
  local name="$1"
  local data_dir="$2"

  if [ ! -f "${data_dir}/.ignition-seed-complete" ]; then
    echo "Seeding data for ${name}..."

    # Copy base ignition data
    cp -dpR /usr/local/bin/ignition/data/* "${data_dir}/"

    # Generate deterministic UUID and save to gateway network location
    UUID=$(echo -n "${name}" | md5sum | awk '{print $1}' | sed 's/\(........\)\(....\)\(....\)\(....\)\(............\)/\1-\2-\3-\4-\5/' | tr -d '[:space:]')
    mkdir -p "${data_dir}/config/local/ignition/gateway-network"
    echo -n "${UUID}" > "${data_dir}/config/local/ignition/gateway-network/uuid.txt"
    echo "Generated UUID for ${name}: ${UUID}"

    # Create empty commissioning.json
    echo "{}" > "${data_dir}/commissioning.json"

    touch "${data_dir}/.ignition-seed-complete"
    echo "Seeding complete for ${name}."
  else
    echo "${name} already seeded, skipping..."
  fi
}

# Iterate over all mounted volumes in /seed
for dir in /seed/*/; do
  [ -d "$dir" ] || continue
  name=$(basename "$dir")
  seed_gateway "$name" "$dir"
done

echo "Bootstrap completed successfully."
