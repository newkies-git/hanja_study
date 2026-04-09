import { describe, expect, it, vi } from "vitest";
import { textIncludesQueryIgnoreCase, withRetry } from "./usePaginatedCollection";

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

describe("withRetry", () => {
  it("첫 시도 성공 시 결과 반환", async () => {
    const fn = vi.fn().mockResolvedValue(42);
    await expect(withRetry(fn)).resolves.toBe(42);
    expect(fn).toHaveBeenCalledTimes(1);
  });

  it("일시 실패 후 성공하면 결과 반환", async () => {
    let attempts = 0;
    const fn = vi.fn().mockImplementation(async () => {
      attempts++;
      if (attempts < 3) throw new Error("일시 오류");
      return "ok";
    });
    // delay를 0으로 단축하기 위해 baseDelayMs=0 전달
    await expect(withRetry(fn, 3, 0)).resolves.toBe("ok");
    expect(fn).toHaveBeenCalledTimes(3);
  });

  it("maxAttempts 초과 시 마지막 오류를 throw", async () => {
    const err = new Error("영구 오류");
    const fn = vi.fn().mockRejectedValue(err);
    await expect(withRetry(fn, 3, 0)).rejects.toThrow("영구 오류");
    expect(fn).toHaveBeenCalledTimes(3);
  });

  it("maxAttempts=1 이면 재시도 없이 즉시 throw", async () => {
    const fn = vi.fn().mockRejectedValue(new Error("즉시 실패"));
    await expect(withRetry(fn, 1, 0)).rejects.toThrow("즉시 실패");
    expect(fn).toHaveBeenCalledTimes(1);
  });
});
