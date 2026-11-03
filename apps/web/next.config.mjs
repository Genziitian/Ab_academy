// Plain JavaScript on purpose: Hostinger's build server has an old glibc, so
// Next falls back to its WebAssembly compiler, which cannot load a
// TypeScript config file.

/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "images.unsplash.com",
      },
      {
        // Course thumbnails uploaded in the admin console.
        protocol: "https",
        hostname: "*.supabase.co",
        pathname: "/storage/v1/object/public/**",
      },
    ],
  },
};

export default nextConfig;
