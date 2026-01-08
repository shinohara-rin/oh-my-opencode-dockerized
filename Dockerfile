# Use the official Bun image
FROM oven/bun:1 AS builder

WORKDIR /app

# Copy package files
COPY package.json bun.lock ./

# Install dependencies (including devDependencies for building)
RUN bun install --frozen-lockfile

# Copy source code
COPY . .

# Build the project
RUN bun run build

# --- Runner Stage ---
FROM oven/bun:1 AS runner

WORKDIR /app

# Copy package files for production install
COPY package.json bun.lock ./

# Install only production dependencies
# This ensures we have the correct native bindings for the runner environment
RUN bun install --production --frozen-lockfile

# Copy built artifacts from builder
COPY --from=builder /app/dist ./dist

# Set up workspace directory for user mounts
WORKDIR /workspace

# Set the entrypoint to the CLI
ENTRYPOINT ["bun", "/app/dist/cli/index.js"]

# Default command
CMD ["--help"]
