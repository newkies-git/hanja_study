import { describe, expect, it } from "vitest";
import { extractSvgPaths, preferLongerSvgPaths } from "./firestoreStrokeMerge";

describe("extractSvgPaths", () => {
  it("빈·비배열이면 []", () => {
    expect(extractSvgPaths({})).toEqual([]);
    expect(extractSvgPaths({ svg_paths: null })).toEqual([]);
    expect(extractSvgPaths({ svg_paths: "x" })).toEqual([]);
  });

  it("문자열만 트림하여 수집", () => {
    expect(
      extractSvgPaths({
        svg_paths: ["  a  ", "", "b", 1, "c"],
      }),
    ).toEqual(["a", "b", "c"]);
  });
});

describe("preferLongerSvgPaths", () => {
  it("길이가 긴 쪽 선택", () => {
    expect(preferLongerSvgPaths(["a"], ["a", "b"])).toEqual(["a", "b"]);
    expect(preferLongerSvgPaths(["a", "b"], ["a"])).toEqual(["a", "b"]);
  });
});
