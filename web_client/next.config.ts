import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  allowedDevOrigins: ["192.168.0.110"],
  experimental: {
    serverActions: {
      allowedOrigins: ["localhost:3001", "192.168.0.110:3001"],
    },
  },
};

export default nextConfig;
