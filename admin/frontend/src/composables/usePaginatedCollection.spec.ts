import { describe, expect, it } from "vitest";
import { textIncludesQueryIgnoreCase } from "./usePaginatedCollection";

describe("textIncludesQueryIgnoreCase", () => {
  it("빈 검색어는 항상 일치", () => {
    expect(textIncludesQueryIgnoreCase("abc", "")).toBe(true);
    expect(textIncludesQueryIgnoreCase("abc", "   ")).toBe(true);
  });

  it("대소문자 무시 부분 일치", () => {
    expect(textIncludesQueryIgnoreCase("Hello", "ell")).toBe(true);
    expect(textIncludesQueryIgnoreCase("Hello", "ELL")).toBe(true);
    expect(textIncludesQueryIgnoreCase("가나다", "나")).toBe(true);
  });

  it("없으면 false", () => {
    expect(textIncludesQueryIgnoreCase("Hello", "xyz")).toBe(false);
  });
});
