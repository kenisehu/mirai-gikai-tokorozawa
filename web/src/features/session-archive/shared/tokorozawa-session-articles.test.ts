import { describe, expect, it } from "vitest";
import {
  findTokorozawaSessionArticle,
  TOKOROZAWA_SESSION_ARTICLES,
} from "./tokorozawa-session-articles";

describe("tokorozawa session articles", () => {
  it("6月と2月の2会議を収録している", () =>
    expect(TOKOROZAWA_SESSION_ARTICLES).toHaveLength(2));
  it("公式発表の件数を保持する", () => {
    expect(findTokorozawaSessionArticle("2026-06")?.proposalCount).toBe(40);
    expect(findTokorozawaSessionArticle("2026-02")?.proposalCount).toBe(42);
  });
  it("存在しない会議は返さない", () =>
    expect(findTokorozawaSessionArticle("unknown")).toBeNull());
});
