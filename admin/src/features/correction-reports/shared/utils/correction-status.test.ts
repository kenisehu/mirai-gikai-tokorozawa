import { describe, expect, it } from "vitest";
import { correctionStatusSchema } from "./correction-status";

describe("correctionStatusSchema", () => {
  it("定義した対応状況のみ許可する", () => {
    for (const value of ["new", "reviewing", "resolved", "dismissed"]) {
      expect(correctionStatusSchema.safeParse(value).success).toBe(true);
    }
    expect(correctionStatusSchema.safeParse("published").success).toBe(false);
  });
});
