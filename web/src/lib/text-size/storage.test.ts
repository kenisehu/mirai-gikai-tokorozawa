import { describe, expect, it } from "vitest";
import { parseStoredTextSizeLarge } from "./storage";

describe("text size storage", () => {
  it("treats only the string true as enabled", () => {
    expect(parseStoredTextSizeLarge("true")).toBe(true);
    expect(parseStoredTextSizeLarge("false")).toBe(false);
    expect(parseStoredTextSizeLarge(null)).toBe(false);
  });
});
