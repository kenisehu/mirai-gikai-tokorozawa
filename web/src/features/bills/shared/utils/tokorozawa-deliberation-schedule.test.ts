import { describe, expect, it } from "vitest";
import { getTokorozawaDeliberationSchedule } from "./tokorozawa-deliberation-schedule";

describe("getTokorozawaDeliberationSchedule", () => {
  it("通常議案は9月14日の採決予定まで表示する", () => {
    const steps = getTokorozawaDeliberationSchedule(
      "令和8年第5回（9月）定例会議",
      "所沢市職員定数条例"
    );
    expect(steps.at(-1)?.title).toBe("委員長報告・討論・採決");
  });

  it("決算案件は決算特別委員会の日程を表示する", () => {
    const steps = getTokorozawaDeliberationSchedule(
      "令和8年第5回（9月）定例会議",
      "令和7年度所沢市一般会計歳入歳出決算の認定について"
    );
    expect(steps.at(-1)?.date).toBe("9月28〜30日");
  });

  it("対象外の会議には固定日程を表示しない", () => {
    expect(getTokorozawaDeliberationSchedule("別の会議", "議案")).toEqual([]);
  });
});
