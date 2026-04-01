import { describe, expect, it } from "vitest";
import { contains } from "./usePaginatedCollection";

describe("contains", () => {
  it("빈 검색어는 항상 일치", () => {
    expect(contains("abc", "")).toBe(true);
    expect(contains("abc", "   ")).toBe(true);
  });

  it("대소문자 무시 부분 일치", () => {
    expect(contains("Hello", "ell")).toBe(true);
    expect(contains("Hello", "ELL")).toBe(true);
    expect(contains("가나다", "나")).toBe(true);
  });

  it("없으면 false", () => {
    expect(contains("Hello", "xyz")).toBe(false);
  });
});
