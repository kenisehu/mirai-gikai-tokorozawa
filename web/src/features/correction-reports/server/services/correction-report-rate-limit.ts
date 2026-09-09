import "server-only";
import { createHmac } from "node:crypto";
import { isIP } from "node:net";
import { createAdminClient } from "@mirai-gikai/supabase";
import { headers } from "next/headers";

export async function allowCorrectionReport(): Promise<boolean> {
  const secret = process.env.SUPABASE_SECRET_KEY;
  if (!secret) return false;
  const requestHeaders = await headers();
  // Vercel overwrites this header. Other production hosts must configure a
  // trusted proxy explicitly rather than accepting arbitrary client headers.
  const ip = process.env.VERCEL
    ? requestHeaders.get("x-forwarded-for")?.split(",")[0]?.trim()
    : process.env.NODE_ENV === "development"
      ? "127.0.0.1"
      : undefined;
  if (!ip || !isIP(ip)) return false;
  const key = createHmac("sha256", secret)
    .update("correction-reports:" + ip)
    .digest("hex");
  const now = Date.now();
  const supabase = createAdminClient();
  for (const [label, duration, limit] of [
    ["minute", 60_000, 1],
    ["hour", 3_600_000, 5],
  ] as const) {
    const { data, error } = await supabase.rpc("increment_api_rate_limit", {
      p_key: `correction:${label}:${key}`,
      p_window_start: new Date(
        Math.floor(now / duration) * duration
      ).toISOString(),
      p_limit: limit,
    });
    // Fail closed if the shared database limit is unavailable.
    if (error || data !== true) return false;
  }
  return true;
}
