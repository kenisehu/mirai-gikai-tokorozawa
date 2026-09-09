import "server-only";
import { createAdminClient } from "@mirai-gikai/supabase";
import { cache } from "react";

export const findMunicipalDeliberationEvents = cache(async (billId: string) => {
  const { data, error } = await createAdminClient()
    .from("municipal_deliberation_events")
    .select(
      "id,event_date,event_type,body_name,summary,question,answer,result,source_url"
    )
    .eq("bill_id", billId)
    .order("display_order")
    .order("event_date");
  if (error) return { events: [], unavailable: true };
  return { events: data ?? [], unavailable: false };
});
