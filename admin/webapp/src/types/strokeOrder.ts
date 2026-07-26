/** 획 폴리라인(정규화 좌표) 한 획 단위 */
export type StrokePoint = [number, number];

export type StrokeShape = { order: number; points: StrokePoint[] };
