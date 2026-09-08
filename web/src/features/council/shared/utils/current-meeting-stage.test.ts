import { describe, expect, it } from "vitest";
import { getCurrentMeetingStage } from "./current-meeting-stage";

describe("getCurrentMeetingStage", () => {
  it.each([
    ["2026-08-31T12:00:00+09:00", "開会前"],
    ["2026-09-04T12:00:00+09:00", "議案質疑・委員会付託"],
    ["2026-09-08T12:00:00+09:00", "委員会審査"],
    ["2026-09-14T12:00:00+09:00", "採決日"],
    ["2026-09-18T12:00:00+09:00", "一般質問"],
    ["2026-09-25T12:00:00+09:00", "会議終了"],
  ])("%s の段階を %s と判定する", (date, expected) => {
    expect(getCurrentMeetingStage(new Date(date)).label).toBe(expected);
  });
});
